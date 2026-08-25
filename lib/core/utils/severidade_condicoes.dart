/// Funções puras de comparação usadas por [AlertaCondicaoNotificationService]
/// pra decidir se uma condição cruzou o limiar configurado pelo usuário (ver
/// `LimiaresAlerta`). Cada uma recebe o limiar como parâmetro em vez de um
/// valor fixo — mantém a lógica testável isolada do carregamento de config.
library;

bool ventoSevero(double kmh, double limiarKmh) => kmh >= limiarKmh;

bool correnteSevera(double nos, double limiarNos) => nos >= limiarNos;

/// Mesmo critério serve pra altura de onda e de swell (mesma unidade, m).
bool alturaSevera(double metros, double limiarM) => metros >= limiarM;

/// Mesmo critério dos outros — dispara "acima de": água quente demais é o
/// que interessa avisar aqui.
bool temperaturaSevera(double celsius, double limiarC) => celsius >= limiarC;
