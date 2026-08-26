class ResumenMensual {
  const ResumenMensual({
    required this.ingresosEnCentavos,
    required this.gastosEnCentavos,
    required this.cantidadMovimientos,
  });

  final int ingresosEnCentavos;
  final int gastosEnCentavos;
  final int cantidadMovimientos;

  int get saldoEnCentavos => ingresosEnCentavos - gastosEnCentavos;
}
