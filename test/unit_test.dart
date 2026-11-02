import 'package:flutter_test/flutter_test.dart';
import 'package:catalog_pro/models/product_model.dart';
import 'package:catalog_pro/controllers/settings_cubit/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ProductModel Tests', () {
    test('should parse ProductModel from JSON', () {
      final json = {
        'id': 1,
        'title': 'iPhone 9',
        'description': 'An apple mobile which is nothing like apple',
        'price': 549.0,
        'rating': 4.69,
        'brand': 'Apple',
        'category': 'smartphones',
        'thumbnail': '...',
        'images': ['...']
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'iPhone 9');
      expect(product.brand, 'Apple');
    });
  });

  group('SettingsCubit Tests', () {
    late SettingsCubit settingsCubit;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getString(any())).thenReturn('en');
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
      settingsCubit = SettingsCubit(mockPrefs);
    });

    test('initial state is English', () {
      expect(settingsCubit.state.languageCode, 'en');
    });

    test('toggleLanguage changes locale to Arabic', () {
      settingsCubit.toggleLanguage();
      expect(settingsCubit.state.languageCode, 'ar');
    });
  });
}
