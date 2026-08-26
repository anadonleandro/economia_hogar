# Economía del Hogar

Aplicación móvil Flutter para registrar ingresos y gastos, consultar el saldo
mensual y analizar los gastos del hogar por categoría.

La primera versión funciona offline, sin login ni backend. Los datos se guardan
localmente en el dispositivo mediante SQLite.

## Estado actual

- Alta, edición y eliminación de movimientos.
- Filtros por tipo, mes y año.
- Resumen mensual y desglose de gastos por categoría.
- Persistencia local y pruebas automatizadas.

## Futuro

- ABM de categorías personalizadas.
- Migración de las categorías actuales desde enum a una tabla SQLite.
- Desactivación de categorías utilizadas para preservar el historial.
- Configuración, exportación y copias de seguridad.
