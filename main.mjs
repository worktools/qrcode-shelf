
import { main_$x_ } from "./js-out/app.main.mjs"
import hud from "bottom-tip"

try {
  main_$x_()
} catch (error) {
  hud("error", String(error))
  throw error
}

if (import.meta.hot) {
  import.meta.hot.accept('./js-out/app.main.mjs', (main) => {
    main.reload_$x_()
  })
}