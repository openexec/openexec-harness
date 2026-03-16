from calc import add, subtract, multiply

def test_add():
    assert add(2, 3) == 5

def test_subtract():
    # This will fail until the bug is fixed
    assert subtract(10, 5) == 5

def test_multiply():
    assert multiply(2, 4) == 8

if __name__ == "__main__":
    import pytest
    import sys
    sys.exit(pytest.main([__file__]))
