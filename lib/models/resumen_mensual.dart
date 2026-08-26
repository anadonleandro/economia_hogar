class ResumenMensual {
  const ResumenMensual({
    required this.ingresosEnCentavos,
    required this.gastosEnCentavos,
    required this.cantidadMovimientos,
    required this.cantidadIngresos,
    required this.cantidadGastos,
  });

  final int ingresosEnCentavos;
  final int gastosEnCentavos;
  final int cantidadMovimientos;
  final int cantidadIngresos;
  final int cantidadGastos;

  int get saldoEnCentavos => ingresosEnCentavos - gastosEnCentavos;
}
