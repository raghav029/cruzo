# API Integration — Slice Merchant

## URL Construction — ApiBasePod + Endpoint Enum

All URLs are constructed via `ApiBasePod`. Never hardcode base URLs.

```dart
// lib/app/core/network/api_base_routes.dart
enum ApiBasePod {
  merchant('/merchant/merchant/external', ApiBaseCluster.banking),
  druid('/druid/api', ApiBaseCluster.banking),
  sahukar('/sahukar/api', ApiBaseCluster.banking),
  repay('/druid/api', ApiBaseCluster.banking),
  comms('/comms', ApiBaseCluster.banking),
  pg('/pg', ApiBaseCluster.banking);
}
```

| Pod | Use for |
|-----|---------|
| `merchant` | Merchant profile, home, transactions, account screens |
| `druid` | Lending, repayment, beneficiaries |
| `sahukar` | Sahukar-specific APIs |
| `comms` | Communications, notifications |
| `pg` | Payment gateway (order groups, PG transactions) |

### Endpoint enum template

```dart
// <feature>/data/<feature>_api_endpoints.dart
import 'package:slice_merchant/app/core/network/api_base_routes.dart';

enum FeatureAPIEndpoints {
  getData('/feature/data', ApiBasePod.merchant),
  postSubmit('/feature/submit', ApiBasePod.merchant),
  getItem('/feature/item/{id}', ApiBasePod.druid);

  final String path;
  final ApiBasePod _pod;
  const FeatureAPIEndpoints(this.path, this._pod);

  String get url => '${_pod.url}$path';
}
```

---

## Making API Calls — Priority Order

### 1. Preferred: `apiService.executeRequest()` (extension on `IAPIServiceInterface`)

Use this for all new repository methods. Returns `ApiResult<T>` with error handling built in.

```dart
// network_util.dart provides this extension
import 'package:slice_merchant/app/utils/network_util.dart';

class FeatureRepoImpl extends FeatureRepo {
  final IAPIServiceInterface apiService;
  FeatureRepoImpl({required this.apiService});

  @override
  Future<ApiResult<FeatureResponse>> getData() {
    return apiService.executeRequest(
      RequestType.get,
      FeatureAPIEndpoints.getData.url,
      null,
      FeatureResponse.fromJson,
    );
  }

  @override
  Future<ApiResult<FeatureResponse>> postSubmit(FeatureRequest request) {
    return apiService.executeRequest(
      RequestType.post,
      FeatureAPIEndpoints.postSubmit.url,
      request.toJson(),
      FeatureResponse.fromJson,
    );
  }
}
```

`executeRequest` wraps `processRequest` + `executeProcessRequest` — you get `ApiResult<T>` directly with DioException mapping and telemetry.

### 2. Acceptable: `executeProcessRequest(() => apiService.processRequest(...))`

More explicit, slightly more verbose. Use when you need fine-grained control over the request call site.

```dart
import 'package:core/core.dart'; // exports executeProcessRequest

Future<ApiResult<FeatureResponse>> getData() {
  return executeProcessRequest(
    () => apiService.processRequest(
      RequestType.get,
      FeatureAPIEndpoints.getData.url,
      null,
      FeatureResponse.fromJson,
    ),
    url: FeatureAPIEndpoints.getData.url,
  );
}
```

### 3. Optional: Retrofit with `executeRetrofitCall()`

Use **only** when you need a typed Retrofit client — e.g., complex path/query parameters, multipart uploads, or APIs already using `@RestApi`. Requires code generation via `build_runner`.

```dart
// <feature>/data/api/<feature>_api_service.dart
import 'package:retrofit/retrofit.dart';
import 'package:core/core.dart';

part '<feature>_api_service.g.dart';

@RestApi()
abstract class FeatureAPIService {
  factory FeatureAPIService(Dio dio, {String baseUrl}) = _FeatureAPIService;

  @GET('/banking/druid/api/feature/{id}')
  Future<FeatureResponse> getItem(@Path('id') String id);

  @DELETE('/banking/druid/api/feature/{id}')
  Future<NavigationResponse> deleteItem(@Path('id') String id);
}
```

```dart
// In the repo — inject via DI (registered in core_module via createRetrofitDio())
class FeatureRepoImpl extends FeatureRepo {
  final FeatureAPIService featureAPIService;
  FeatureRepoImpl({required this.featureAPIService});

  @override
  Future<ApiResult<FeatureResponse>> getItem(String id) {
    return executeRetrofitCall(
      () => featureAPIService.getItem(id),
      url: '/banking/druid/api/feature/$id',
    );
  }
}
```

### 4. Legacy (avoid in new code): `apiService.processRequest()` directly

Returns `APIResponse<T>` — requires manual null/error unwrapping. Still exists in older repos (home, rewards), do not replicate this pattern.

```dart
// DO NOT use in new code
final response = await apiService.processRequest<FeatureResponse>(
  RequestType.get,
  FeatureAPIEndpoints.getData.url,
  null,
  FeatureResponse.fromJson,
);
if (response.error != null) { ... }  // manual handling required
```

---

## `ApiResult<T>` — Handling Responses

All preferred patterns return `ApiResult<T>` (a sealed class from `core`):

```dart
final result = await featureRepo.getData();

switch (result) {
  case Success<FeatureResponse>(:final data):
    emit(FeatureLoaded(data: data));
  case Error<FeatureResponse>(:final error):
    emit(FeatureError(message: error.message));
}
```

Or with `when`:

```dart
result.when(
  success: (data) => emit(FeatureLoaded(data: data)),
  error: (error) => emit(FeatureError(message: error.message)),
);
```

---

## Safe Call Pattern (for `APIResponse` legacy repos)

If you're adding to an existing repo that uses `processRequest` directly, wrap with a local `_safeCall`:

```dart
Future<ApiResult<T>> _safeCall<T>(Future<APIResponse<T>> Function() call) async {
  try {
    final response = await call();
    if (response.error != null) return Error(response.error!);
    final data = response.data;
    if (data == null) {
      return Error(ErrorInfo(message: 'No data', type: ErrorInfoType.serverError));
    }
    return Success(data);
  } catch (e) {
    return Error(ErrorInfo(message: e.toString(), type: ErrorInfoType.serverError));
  }
}
```
