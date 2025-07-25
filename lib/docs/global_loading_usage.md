# Global Loading System - Hướng dẫn sử dụng

## Tổng quan

Hệ thống Global Loading cho phép hiển thị loading overlay toàn màn hình khi chuyển tab hoặc thực hiện các tác vụ cần loading.

## Cách sử dụng

### 1. Sử dụng với Extension (Khuyến nghị)

```dart
import 'package:AirVibe/extensions/provider_loading_extension.dart';

// Trong ConsumerWidget
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Cách 1: Wrap future với loading
        final result = await ref.withGlobalLoading(
          ApiHelper.getCurrentWeather(),
          loadingMessage: 'Đang tải thời tiết...',
        );
        
        // Cách 2: Manual control
        ref.startGlobalLoading('Đang xử lý...');
        await Future.delayed(Duration(seconds: 2));
        ref.updateLoadingMessage('Gần xong rồi...');
        await Future.delayed(Duration(seconds: 1));
        ref.stopGlobalLoading();
      },
      child: Text('Load Data'),
    );
  }
}
```

### 2. Sử dụng trực tiếp với Provider

```dart
// Trong ConsumerWidget
final globalLoading = ref.read(globalLoadingProvider.notifier);

// Bắt đầu loading
globalLoading.startLoading('Đang tải dữ liệu...');

// Cập nhật message
globalLoading.updateMessage('Đang xử lý...');

// Dừng loading
globalLoading.stopLoading();
```

### 3. Tích hợp với Tab Loading

Hệ thống tự động xử lý loading khi chuyển tab thông qua `TabLoadingManager`.

## Customization

### Thay đổi LoadingWidget

Chỉnh sửa file `lib/widgets/loading_widget.dart` để thay đổi animation loading.

### Thay đổi Overlay UI

Chỉnh sửa file `lib/widgets/global_loading_overlay.dart` để custom giao diện overlay.

## Tips

1. **Không lạm dụng**: Chỉ dùng cho các tác vụ thực sự cần thiết
2. **Message rõ ràng**: Sử dụng message mô tả chính xác việc đang làm  
3. **Timeout**: Luôn có cơ chế timeout để tránh loading vô hạn
4. **Error handling**: Đảm bảo stopLoading() được gọi trong finally block

## Architecture

```
GlobalLoadingProvider (StateNotifier)
    ↓
GlobalLoadingOverlay (Widget)
    ↓  
LoadingWidget (Custom Animation)
```