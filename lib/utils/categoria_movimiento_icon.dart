import 'package:flutter/material.dart';

import '../models/categoria_movimiento.dart';

IconData categoriaMovimientoIcon(CategoriaMovimiento categoria) {
  return switch (categoria) {
    CategoriaMovimiento.alimentos => Icons.restaurant_outlined,
    CategoriaMovimiento.servicios => Icons.receipt_long_outlined,
    CategoriaMovimiento.transporte => Icons.directions_car_outlined,
    CategoriaMovimiento.vivienda => Icons.home_outlined,
    CategoriaMovimiento.salud => Icons.medical_services_outlined,
    CategoriaMovimiento.educacion => Icons.school_outlined,
    CategoriaMovimiento.ocio => Icons.movie_outlined,
    CategoriaMovimiento.ropa => Icons.checkroom_outlined,
    CategoriaMovimiento.otrosGastos => Icons.more_horiz,
    CategoriaMovimiento.sueldo => Icons.payments_outlined,
    CategoriaMovimiento.trabajoExtra => Icons.work_outline,
    CategoriaMovimiento.venta => Icons.sell_outlined,
    CategoriaMovimiento.inversion => Icons.trending_up,
    CategoriaMovimiento.otrosIngresos => Icons.savings_outlined,
  };
}
