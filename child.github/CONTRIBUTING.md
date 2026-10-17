# Cómo contribuir a Recursos FAMAF

¡Gracias por querer sumar! Cualquier persona puede aportar apuntes, prácticos, libros o exámenes, y también corregir lo que ya existe. No necesitas saber Git para empezar.

## Elige cómo aportar

1. **Desde la [página web](https://shirosweets.github.io/Web-Page-FAMAF-Resources)**: la forma más sencilla de agregar contenido.
2. **Desde GitHub, sin instalar nada**: en el repositorio de la materia usa **Add file → Upload files**, elige la carpeta y abre el pull request desde el mismo botón.
3. **Con Git**: haz un fork, crea una rama, agrega tus archivos y abre un pull request.
4. **Sin subir archivos**: abre un [issue](../../../issues/new/choose) para pedir un recurso o reportar un problema.

## Dónde van los archivos

| Carpeta | Contenido |
|---------|-----------|
| `apuntes/` | Apuntes y resúmenes |
| `practico/` | Prácticos y su resolución |
| `teorico/` | Material teórico |
| `libros/` | Libros y bibliografía |

## Reglas para los archivos

- **Nombres sin espacios ni caracteres especiales** (`#`, `%`, `&`, `:`, `?`, `*`, comillas, etc.). Usa `_` o `-`. Los acentos son válidos, pero conviene evitarlos.
- **Máximo 50 MB por archivo** (desde 20 MB se recomienda comprimir).
- **No se aceptan ejecutables ni instaladores** (`.exe`, `.msi`, `.jar`, etc.).
- **Comparte solo lo que tengas derecho a compartir**: material propio, publicado por la cátedra o con una licencia que lo permita. Si hay dudas, abre un issue antes.
- No incluyas datos personales de otras personas.

## Qué pasa cuando abres un pull request

Varios chequeos automáticos te acompañan:

- **Validación de estructura**: revisa los archivos nuevos y te avisa en **Files changed** y en el resumen del check. Los *errores* (nombre inválido, archivo muy pesado, ejecutable) deben corregirse; los *avisos* (carpeta no estándar, acentos) son sugerencias.
- **Etiquetas** según las carpetas modificadas y **asignación automática de revisores**.
- Una persona del equipo revisará tu aporte. Si piden cambios, súbelos a la misma rama y el PR se actualiza solo.

Si es tu primer aporte aceptado, ¡te lo vamos a agradecer! 🎉

## ¿Dudas?

Abre un issue y te ayudamos.
