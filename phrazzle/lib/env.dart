class Env {
    static const _errorDefault = 'Goofed';
    static const apiUrl = String.fromEnvironment('API_URL', defaultValue: _errorDefault);
    Env._();
}