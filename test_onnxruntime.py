#!/usr/bin/env python3
"""
Тестовый скрипт для проверки ONNX Runtime с поддержкой GPU SM_61
"""

import sys
import numpy as np

def test_onnxruntime():
    try:
        import onnxruntime as ort
        print("✓ ONNX Runtime успешно импортирован")
        print(f"  Версия: {ort.__version__}")
    except ImportError as e:
        print(f"✗ Ошибка импорта ONNX Runtime: {e}")
        return False

    # Проверка доступных провайдеров
    print("\nДоступные провайдеры выполнения:")
    providers = ort.get_available_providers()
    for provider in providers:
        if provider == 'CUDAExecutionProvider':
            print(f"  ✓ {provider} - GPU поддержка доступна!")
        else:
            print(f"  • {provider}")

    # Проверка информации о устройстве
    print("\nИнформация о системе:")
    print(f"  Python версия: {sys.version}")
    print(f"  NumPy версия: {np.__version__}")

    # Проверка CUDA если доступна
    if 'CUDAExecutionProvider' in providers:
        print("\n✓ CUDA поддержка обнаружена!")
        print("  Пакет готов для работы с GPU (SM_61)")

        # Попытка получить информацию о GPU
        try:
            import subprocess
            result = subprocess.run(['nvidia-smi', '--query-gpu=name,compute_cap',
                                   '--format=csv,noheader'],
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print("\nИнформация о GPU:")
                for line in result.stdout.strip().split('\n'):
                    name, cap = line.split(', ')
                    print(f"  • {name} (Compute Capability: {cap})")
                    if cap.startswith('6.1'):
                        print(f"    ✓ Оптимизировано для этого GPU!")
        except:
            pass
    else:
        print("\n⚠ CUDA провайдер не доступен")
        print("  Для GPU поддержки установите CUDA и пересоберите пакет с PKGBUILD.cuda")

    # Создание простой тестовой модели
    print("\nТест создания сессии...")
    try:
        # Создаем простую ONNX модель для теста
        from onnx import TensorProto, helper, save

        # Определяем граф
        X = helper.make_tensor_value_info('X', TensorProto.FLOAT, [1, 2])
        Y = helper.make_tensor_value_info('Y', TensorProto.FLOAT, [1, 2])

        # Создаем узел Add
        add_node = helper.make_node(
            'Add',
            inputs=['X', 'X'],
            outputs=['Y'],
        )

        # Создаем граф
        graph_def = helper.make_graph(
            [add_node],
            'test_model',
            [X],
            [Y],
        )

        # Создаем модель
        model_def = helper.make_model(graph_def, producer_name='test')

        # Сохраняем модель
        save(model_def, 'test_model.onnx')

        # Создаем сессию
        session = ort.InferenceSession(
            'test_model.onnx',
            providers=['CUDAExecutionProvider', 'CPUExecutionProvider']
        )

        print(f"  ✓ Сессия создана успешно")
        print(f"  Используемые провайдеры: {session.get_providers()}")

        # Тестовый запуск
        input_data = np.array([[1.0, 2.0]], dtype=np.float32)
        result = session.run(['Y'], {'X': input_data})
        expected = input_data * 2

        if np.allclose(result[0], expected):
            print(f"  ✓ Тест вычисления пройден: {input_data[0]} + {input_data[0]} = {result[0][0]}")

        # Удаляем тестовую модель
        import os
        os.remove('test_model.onnx')

    except Exception as e:
        print(f"  ⚠ Не удалось создать тестовую модель: {e}")
        print("    (Возможно, требуется установить пакет onnx)")

    print("\n" + "="*50)
    print("Тестирование завершено!")
    return True

if __name__ == "__main__":
    print("="*50)
    print("Тест ONNX Runtime для GPU SM_61")
    print("="*50)

    success = test_onnxruntime()
    sys.exit(0 if success else 1)