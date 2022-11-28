
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |lilac/ |memof/ |respo-ui.calcit/ |respo-markdown.calcit/ |reel.calcit/ |respo-feather.calcit/ |alerts.calcit/
  :entries $ {}
  :files $ {}
    |app.comp.barcode $ {}
      :defs $ {}
        |barcodes-list $ quote
          def barcodes-list $ []
            {} (:value :code-128) (:display "\"CODE128")
            {} (:value :gs1-128) (:display "\"GS1-128")
        |comp-barcode $ quote
          defcomp comp-barcode (states code code-data)
            let
                code-menu-plugin $ use-modal-menu (>> states :codes)
                  {} (:title |Demo)
                    :style $ {} (:width 300)
                    :backdrop-style $ {}
                    :items barcodes-list
                    :on-result $ fn (result d!)
                      d! :code-format $ {}
                        :id $ :id code-data
                        :format result
              []
                effect-render-code code $ :barcode-format code-data
                div
                  {} $ :style ui/center
                  div ({})
                    img $ {}
                  .render code-menu-plugin
        |effect-render-code $ quote
          defeffect effect-render-code (code format) (action el)
            when
              or (= action :mount) (= action :update)
              -> code qrcode/toDataURL
                .!then $ fn (url)
                  -> el (.!querySelector "\"img") (.!setAttribute "\"src" url)
                  jsbarcode
                    -> el $ .!querySelector "\"img"
                    , code $ to-js-data
                      merge
                        {} $ :displayValue false
                        case-default format nil
                          :gs1-128 $ {} (:format "\"CODE128") (:ean128 true)
                          :code-128 $ {} (:format "\"CODE128")
                .!catch $ fn (error) (js/console.error error)
                  -> el (.!querySelector "\"img") (.!setAttribute "\"src" "\"")
                  -> el (.!querySelector "\"img") (.!setAttribute "\"alt" "\"Failed to render")
      :ns $ quote
        ns app.comp.barcode $ :require
          respo-ui.core :refer $ hsl
          respo-ui.core :as ui
          respo.core :refer $ defcomp defeffect >> <> div button textarea span input img
          respo.comp.space :refer $ =<
          reel.comp.reel :refer $ comp-reel
          respo-md.comp.md :refer $ comp-md
          app.config :refer $ dev?
          "\"qrcode" :as qrcode
          "\"jsbarcode" :default jsbarcode
          respo-alerts.core :refer $ use-modal-menu comp-modal-menu
    |app.comp.container $ {}
      :defs $ {}
        |comp-container $ quote
          defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
                remove-plugin $ use-confirm (>> states :remove)
                  {} $ :text "\"Are use sure to remove?"
                  , 
                create-plugin $ use-prompt (>> states :create)
                  {}
                    :input-style $ {} (:font-family ui/font-code)
                    :text "\"Add new code"
                    :button-text "\"Render"
              [] (effect-layout)
                div
                  {} $ :style (merge ui/global ui/fullscreen ui/column)
                  if
                    some? $ :pointer store
                    div
                      {} $ :style (merge ui/expand ui/column)
                      div
                        {} $ :style
                          merge ui/row-parted $ {} (:padding 8)
                        span nil
                        comp-icon :arrow-up
                          {} (:font-size 20)
                            :color $ hsl 200 80 80
                            :cursor :pointer
                          fn (e d!)
                            d! :touch-code $ :pointer store
                            when-let
                              target $ js/document.querySelector "\".scroll-area"
                              -> target .-firstElementChild $ .!scrollIntoViewIfNeeded
                                js-object $ :behavior "\"smooth"
                      let
                          code-data $ get-in store
                            [] :codes $ :pointer store
                          code $ :code code-data
                        div
                          {} $ :style (merge ui/expand ui/center)
                          div
                            {} $ :style ui/row-middle
                            <> code $ {} (:font-size 20) (:font-family ui/font-code)
                            =< 8 nil
                            comp-icon :toggle-right
                              {} (:size 20)
                                :color $ hsl 0 0 80
                                :font-size 20
                                :cursor :pointer
                              fn (e d!)
                                d! :toggle-barcode $ :id code-data
                          if (:barcode? code-data)
                            comp-barcode (>> states :barcode) code code-data
                            comp-qrcode code
                          comp-note (>> states :note) code-data
                      div
                        {} $ :style
                          merge ui/row-parted $ {} (:padding 16)
                        span nil
                        span
                          {} $ :on-click
                            fn (e d!)
                              .show remove-plugin d! $ fn ()
                                d! :remove-code $ :pointer store
                                let
                                    new-pointer $ first
                                      keys $ dissoc (:codes store) (:pointer store)
                                    next-code $ get-in store ([] :codes new-pointer :code)
                                  d! :pointer new-pointer
                          comp-i :x-circle 20 $ hsl 0 80 70
                    div
                      {} $ :style
                        merge ui/expand ui/center $ {} (:font-family ui/font-fancy) (:font-size 24)
                          :color $ hsl 0 0 80
                      <> "\"No selection"
                  comp-sidebar states store
                  div
                    {} $ :style
                      merge ui/center $ {} (:padding 16) (:margin :auto)
                    span
                      {}
                        :style $ {} (:cursor :pointer)
                        :on-click $ fn (e d!)
                          .show create-plugin d! $ fn (result)
                            when-not (.blank? result) (d! :add-code result)
                      comp-i :plus-square 28 $ hsl 200 80 80
                  .render remove-plugin
                  .render create-plugin
                  when dev? $ comp-reel (>> states :reel) reel ({})
                  when dev? $ comp-inspect "\"store" store
                    {} $ :bottom 0
        |comp-note $ quote
          defcomp comp-note (states code)
            let
                note-plugin $ use-prompt (>> states :create)
                  {} (:text "\"Some note:") (:button-text "\"Add")
                    :initial $ :note code
              div
                {} $ :style ui/row-middle
                <>
                  or (:note code) "\"..."
                  {} $ :color (hsl 0 0 70)
                =< 8 nil
                span
                  {}
                    :style $ {} (:cursor :pointer)
                    :on-click $ fn (e d!)
                      .show note-plugin d! $ fn (result)
                        d! :note-code $ {}
                          :id $ :id code
                          :note $ if (.blank? result) nil result
                  comp-i :edit 14 $ hsl 0 0 80
                .render note-plugin
        |comp-sidebar $ quote
          defcomp comp-sidebar (states store)
            div
              {} $ :style
                merge ui/expand $ {}
                  :background-color $ hsl 0 0 96
                  :display :flex
                  :padding "\"10px 60px"
              list->
                {}
                  :style $ merge
                    {} (:margin :auto) (:white-space :nowrap)
                  :class-name "\"scroll-area"
                -> (:codes store) vals .to-list
                  .sort-by $ fn (code)
                    - 0 $ :time code
                  .map $ fn (code)
                    [] (:id code)
                      div
                        {}
                          :style $ merge style-card
                            if
                              = (:id code) (:pointer store)
                              {} $ :background-color :white
                          :on-click $ fn (e d!)
                            d! :pointer $ :id code
                        div ({})
                          <> (:code code)
                            {} (:font-size 16) (:line-height "\"40px") (:display :inline-block)
                        div ({})
                          <> (:note code)
                            {}
                              :color $ hsl 0 0 80
                              :font-family ui/font-normal
                              :font-size 12
                        div ({})
                          if (:barcode? code)
                            comp-i :bar-chart 16 $ hsl 0 0 0
        |effect-layout $ quote
          defeffect effect-layout () (action el)
            ; when (< js/window.innerWidth 800)
              set! (-> el .-style .-flexDirection) "\"column"
              set! (-> el .-style .-flexDirection) "\"column-reverse"
              set! (-> el .-firstElementChild .-style .-maxWidth) "\"800px"
              js/console.log (-> el .-style .-maxWidth .-firstElementChild) el
        |style-card $ quote
          def style-card $ {} (:padding "\"12px 12px") (:font-size 18) (:font-family ui/font-code) (:cursor :pointer)
            :border-bottom $ str "\"1px solid " (hsl 0 0 88)
            :text-overflow :ellipsis
            :overflow :hidden
            :min-width 60
            :height 120
            :display :inline-block
      :ns $ quote
        ns app.comp.container $ :require
          respo-ui.core :refer $ hsl
          respo-ui.core :as ui
          respo.core :refer $ defcomp defeffect >> list-> <> div button textarea span input
          respo.comp.space :refer $ =<
          respo.comp.inspect :refer $ comp-inspect
          reel.comp.reel :refer $ comp-reel
          respo-md.comp.md :refer $ comp-md
          app.config :refer $ dev?
          feather.core :refer $ comp-icon comp-i
          respo-alerts.core :refer $ use-prompt use-confirm use-prompt
          app.comp.qrcode :refer $ comp-qrcode
          app.comp.barcode :refer $ comp-barcode
          "\"qrcode" :as qrcode
    |app.comp.qrcode $ {}
      :defs $ {}
        |comp-qrcode $ quote
          defcomp comp-qrcode (code)
            [] (effect-render-code code)
              div ({})
                img $ {}
        |effect-render-code $ quote
          defeffect effect-render-code (code) (action el)
            when
              or (= action :mount) (= action :update)
              -> code qrcode/toDataURL
                .then $ fn (url)
                  -> el (.querySelector "\"img") (.setAttribute "\"src" url)
                .catch $ fn (error) (js/console.error error)
      :ns $ quote
        ns app.comp.qrcode $ :require
          respo-ui.core :refer $ hsl
          respo-ui.core :as ui
          respo.core :refer $ defcomp defeffect <> div button textarea span input img
          respo.comp.space :refer $ =<
          reel.comp.reel :refer $ comp-reel
          respo-md.comp.md :refer $ comp-md
          app.config :refer $ dev?
          "\"qrcode" :as qrcode
    |app.config $ {}
      :defs $ {}
        |dev? $ quote
          def dev? $ = "\"dev" (get-env "\"mode" "\"release")
        |site $ quote
          def site $ {} (:dev-ui "\"http://localhost:8100/main-fonts.css") (:release-ui "\"http://cdn.tiye.me/favored-fonts/main-fonts.css") (:cdn-url "\"http://cdn.tiye.me/qrcode-shelf/") (:title "\"QR Code") (:icon "\"http://cdn.tiye.me/logo/qrcode-shelf.png") (:storage-key "\"qrcode-shelf")
      :ns $ quote (ns app.config)
    |app.main $ {}
      :defs $ {}
        |*reel $ quote
          defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when
              and config/dev? $ not= op :states
              println "\"Dispatch:" op op-data
            reset! *reel $ reel-updater updater @*reel op op-data
        |main! $ quote
          defn main! ()
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            if config/dev? $ load-console-formatter!
            render-app!
            add-watch *reel :changes $ fn (s p) (render-app!)
            listen-devtools! |a dispatch!
            js/window.addEventListener |beforeunload $ fn (e) (persist-storage!)
            flipped js/setInterval 60000 persist-storage!
            let
                raw $ js/localStorage.getItem (:storage-key config/site)
              when (some? raw)
                dispatch! :hydrate-storage $ parse-cirru-edn raw
            println "|App started."
        |mount-target $ quote
          def mount-target $ .querySelector js/document |.app
        |persist-storage! $ quote
          defn persist-storage! () $ js/localStorage.setItem (:storage-key config/site)
            format-cirru-edn $ :store @*reel
        |reload! $ quote
          defn reload! () (clear-cache!)
            reset! *reel $ refresh-reel @*reel schema/store updater
            println "|Code updated."
        |render-app! $ quote
          defn render-app! () $ render! mount-target (comp-container @*reel) dispatch!
        |snippets $ quote
          defn snippets () $ println config/cdn?
      :ns $ quote
        ns app.main $ :require
          [] respo.core :refer $ [] render! clear-cache! realize-ssr!
          [] app.comp.container :refer $ [] comp-container
          [] app.updater :refer $ [] updater
          [] app.schema :as schema
          [] reel.util :refer $ [] listen-devtools!
          [] reel.core :refer $ [] reel-updater refresh-reel
          [] reel.schema :as reel-schema
          [] cljs.reader :refer $ [] read-string
          [] app.config :as config
          [] medley.core :refer $ [] dissoc-in
    |app.schema $ {}
      :defs $ {}
        |code $ quote
          def code $ {} (:id nil) (:code nil) (:note nil) (:timestamp nil) (:barcode? false) (:barcode-format nil)
        |store $ quote
          def store $ {}
            :states $ {}
            :codes $ do code ({})
            :pointer nil
      :ns $ quote (ns app.schema)
    |app.updater $ {}
      :defs $ {}
        |updater $ quote
          defn updater (store op op-data op-id op-time)
            case-default op
              do (js/console.log "\"Unknown op" op) store
              :states $ update-states store op-data
              :content $ assoc store :content op-data
              :hydrate-storage op-data
              :add-code $ -> store
                assoc-in ([] :codes op-id)
                  merge schema/code $ {} (:id op-id) (:code op-data) (:time op-time)
                assoc :pointer op-id
              :touch-code $ assoc-in store ([] :codes op-data :time) op-time
              :pointer $ assoc store :pointer op-data
              :remove-code $ -> store
                dissoc-in $ [] :codes op-data
                assoc :pointer nil
              :note-code $ let
                  code-id $ :id op-data
                  note $ :note op-data
                assoc-in store ([] :codes code-id :note) note
              :code-format $ let
                  code-id $ :id op-data
                  format $ :format op-data
                assoc-in store ([] :codes code-id :barcode-format) format
              :toggle-barcode $ update-in store ([] :codes op-data :barcode?) not
      :ns $ quote
        ns app.updater $ :require
          respo.cursor :refer $ update-states
          app.schema :as schema
