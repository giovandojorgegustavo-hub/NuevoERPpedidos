# Pruebas unitarias del shell

Se añadieron pruebas enfocadas en los controladores extraídos para el shell
(`NavigationController`, `SectionStateController`, `SectionConfigBuilders`).
Estas pruebas viven en `test/shell/controllers/` y se ejecutan con:

```
flutter test test/shell/controllers
```

Cubre:
- Navegación (cambio de módulo/sección, stack de `NavigationSnapshot`).
- Estado por sección (data sources, overrides, modos de formulario).
- Builders de Table/Detail/Form (verificación de columnas, campos y callbacks).

Cuando se agreguen controladores nuevos o se extienda la funcionalidad, añade
pruebas similares en este directorio para mantener la cobertura.
