
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
                  {} $ 
                    :title |Demo
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
                .then $ fn (url)
                  -> el (.querySelector "\"img") (.setAttribute "\"src" url)
                  jsbarcode
                    -> el $ .querySelector "\"img"
                    , code $ clj->js
                      merge
                        {} $ :displayValue false
                        case format
                          :gs1-128 $ {} (:format "\"CODE128") (:ean128 true)
                          :code-128 $ {} (:format "\"CODE128")
                          do nil
                .catch $ fn (error) (js/console.error error)
                  -> el (.querySelector "\"img") (.setAttribute "\"src" "\"")
                  -> el (.querySelector "\"img") (.setAttribute "\"alt" "\"Failed to render")
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
          "\"jsbarcode" :as jsbarcode
          respo-alerts.core :refer $ use-modal-menu comp-modal-menu
    |app.comp.container $ {}
      :defs $ {}
        |comp-container $ quote
          defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
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
                          fn (e d! m!)
                            d! :touch-code $ :pointer store
                            when-let
                              target $ js/document.querySelector "\".scroll-area"
                              .. target -firstElementChild $ scrollIntoViewIfNeeded
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
                              fn (e d! m!)
                                d! :toggle-barcode $ :id code-data
                          if (:barcode? code-data)
                            comp-barcode (>> states :barcode) code code-data
                            comp-qrcode code
                          comp-note (>> states :note) code-data
                      div
                        {} $ :style
                          merge ui/row-parted $ {} (:padding 16)
                        span nil
                        comp-confirm (>> states :remove)
                          {}
                            :trigger $ comp-i :x-circle 20 (hsl 0 80 70)
                            :text "\"Are use sure to remove?"
                          fn (e d! m!)
                            d! :remove-code $ :pointer store
                            let
                                new-pointer $ first
                                  keys $ dissoc (:codes store) (:pointer store)
                                next-code $ get-in store ([] :codes new-pointer :code)
                              d! :pointer new-pointer
                    div
                      {} $ :style
                        merge ui/expand ui/center $ {} (:font-family ui/font-fancy) (:font-size 24)
                          :color $ hsl 0 0 80
                      <> "\"No selection"
                  comp-sidebar states store
                  div
                    {} $ :style
                      merge ui/center $ {} (:padding 16) (:margin :auto)
                    comp-prompt (>> states :create)
                      {}
                        :trigger $ comp-i :plus-square 28 (hsl 200 80 80)
                        :input-style $ {} (:font-family ui/font-code)
                        :text "\"Add new code"
                        :button-text "\"Render"
                      fn (result d! m!)
                        when-not (string/blank? result) (d! :add-code result)
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
                  {} $ :on-click
                    fn (e d!)
                      .show note-plugin $ fn (result d!)
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
                ->> (:codes store) vals
                  sort-by $ fn (code)
                    - 0 $ :time code
                  map $ fn (code)
                    [] (:id code)
                      div
                        {}
                          :style $ merge style-card
                            if
                              = (:id code) (:pointer store)
                              {} $ :background-color :white
                          :on-click $ fn (e d! m!)
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
          respo-alerts.core :refer $ comp-prompt comp-confirm use-prompt
          clojure.string :as string
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
          [] hsl.core :refer $ [] hsl
          [] respo-ui.core :as ui
          [] respo.core :refer $ [] defcomp defeffect <> div button textarea span input img
          [] respo.comp.space :refer $ [] =<
          [] reel.comp.reel :refer $ [] comp-reel
          [] respo-md.comp.md :refer $ [] comp-md
          [] app.config :refer $ [] dev?
          [] "\"qrcode" :as qrcode
    |app.config $ {}
      :defs $ {}
        |cdn? $ quote
          def cdn? $ cond
              exists? js/window
              , false
            (exists? js/process) (= "\"true" js/process.env.cdn)
            :else false
        |dev? $ quote
          def dev? $ let
              debug? $ do ^boolean js/goog.DEBUG
            cond
                exists? js/window
                , debug?
              (exists? js/process) (not= "\"true" js/process.env.release)
              :else true
        |site $ quote
          def site $ {} (:dev-ui "\"http://localhost:8100/main-fonts.css") (:release-ui "\"http://cdn.tiye.me/favored-fonts/main-fonts.css") (:cdn-url "\"http://cdn.tiye.me/qrcode-shelf/") (:title "\"QR Code") (:icon "\"http://cdn.tiye.me/logo/qrcode-shelf.png") (:storage-key "\"qrcode-shelf")
      :ns $ quote (ns app.config)
    |app.main $ {}
      :defs $ {}
        |*reel $ quote
          defonce *reel $ atom
            -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when
              and config/dev? $ not= op :states
              println "\"Dispatch:" op op-data
            reset! *reel $ reel-updater updater @*reel op op-data
        |main! $ quote
          defn main! ()
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            if ssr? $ render-app! realize-ssr!
            render-app! render!
            add-watch *reel :changes $ fn () (render-app! render!)
            listen-devtools! |a dispatch!
            .addEventListener js/window |beforeunload persist-storage!
            repeat! 60 persist-storage!
            let
                raw $ .getItem js/localStorage (:storage-key config/site)
              when (some? raw)
                dispatch! :hydrate-storage $ read-string raw
            println "|App started."
        |mount-target $ quote
          def mount-target $ .querySelector js/document |.app
        |persist-storage! $ quote
          defn persist-storage! () $ .setItem js/localStorage (:storage-key config/site)
            pr-str $ :store @*reel
        |reload! $ quote
          defn reload! () (clear-cache!)
            reset! *reel $ refresh-reel @*reel schema/store updater
            println "|Code updated."
        |render-app! $ quote
          defn render-app! (renderer)
            renderer mount-target (comp-container @*reel) ("#()" dispatch! %1 %2)
        |snippets $ quote
          defn snippets () $ println config/cdn?
        |ssr? $ quote
          def ssr? $ some? (js/document.querySelector |meta.respo-ssr)
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
          [] cumulo-util.core :refer $ [] repeat!
          [] medley.core :refer $ [] dissoc-in
    |app.page $ {}
      :defs $ {}
        |base-info $ quote
          def base-info $ {}
            :title $ :title config/site
            :icon $ :icon config/site
            :ssr nil
            :inline-html nil
            :manifest "\"manifest.json"
        |dev-page $ quote
          defn dev-page () $ make-page |
            merge base-info $ {}
              :styles $ [] (<< "\"http://~(get-ip!):8100/main.css") "\"/entry/main.css"
              :scripts $ [] "\"/client.js"
              :inline-styles $ []
        |main! $ quote
          defn main! ()
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            if config/dev?
              spit "\"target/index.html" $ dev-page
              spit "\"dist/index.html" $ prod-page
        |prod-page $ quote
          defn prod-page () $ let
              reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
              html-content $ make-string (comp-container reel)
              assets $ read-string (slurp "\"dist/assets.edn")
              cdn $ if config/cdn? (:cdn-url config/site) "\""
              prefix-cdn $ fn (x) (str cdn x)
            make-page html-content $ merge base-info
              {}
                :styles $ [] (:release-ui config/site)
                :scripts $ map ("#()" -> % :output-name prefix-cdn) assets
                :ssr "\"respo-ssr"
                :inline-styles $ [] (slurp "\"./entry/main.css")
                :append-html nil
      :ns $ quote
        ns app.page
          :require
            [] respo.render.html :refer $ [] make-string
            [] shell-page.core :refer $ [] make-page spit slurp
            [] app.comp.container :refer $ [] comp-container
            [] app.schema :as schema
            [] reel.schema :as reel-schema
            [] cljs.reader :refer $ [] read-string
            [] app.config :as config
            [] cumulo-util.build :refer $ [] get-ip!
          :require-macros $ [] clojure.core.strint :refer ([] <<)
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
            case op
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
              , store
      :ns $ quote
        ns app.updater $ :require
          [] respo.cursor :refer $ [] update-states
          [] app.schema :as schema
          [] medley.core :refer $ [] dissoc-in
