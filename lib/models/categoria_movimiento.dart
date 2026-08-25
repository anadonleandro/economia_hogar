import 'tipo_movimiento.dart';

enum CategoriaMovimiento {
  alimentos('Alimentos', TipoMovimiento.gasto),
  servicios('Servicios', TipoMovimiento.gasto),
  transporte('Transporte', TipoMovimiento.gasto),
  vivienda('Vivienda', TipoMovimiento.gasto),
  salud('Salud', TipoMovimiento.gasto),
  educacion('Educación', TipoMovimiento.gasto),
  ocio('Ocio', TipoMovimiento.gasto),
  ropa('Ropa', TipoMovimiento.gasto),
  otrosGastos('Otros', TipoMovimiento.gasto),

  sueldo('Sueldo', TipoMovimiento.ingreso),
  trabajoExtra('Trabajo extra', TipoMovimiento.ingreso),
  venta('Venta', TipoMovimiento.ingreso),
  inversion('Inversión', TipoMovimiento.ingreso),
  otrosIngresos('Otros', TipoMovimiento.ingreso);

  const CategoriaMovimiento(this.nombre, this.tipo);

  final String nombre;
  final TipoMovimiento tipo;
}
