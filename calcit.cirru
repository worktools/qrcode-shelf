
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |alerts.calcit/ |js-ffi/ |respo-feather.calcit/
      :type-slots $ {} $ :dispatch-op |app.schema/Op
  :files $ {}
    'app.comp.barcode $ %{} 'FileEntry
      :defs $ {}
        'barcodes-list $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def barcodes-list
            [] (:: :item :code-128 |CODE128) (:: :item :gs1-128 |GS1-128)
          :examples $ []
        'comp-barcode $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-barcode (states code code-data)
            let
                code-menu-plugin $ use-modal-menu (>> states :codes)
                  {} (:title |Demo)
                    :style $ {} $ :width 300
                    :backdrop-style $ {}
                    :items barcodes-list
                    :on-result $ fn (result d!)
                      hint-fn $ {}
                        :args $ [] 'Dynamic $ :: 'Fn
                          {}
                            :args $ [] 'Enum
                            :return 'Unit
                        :return 'Unit
                      d! $ :: :code-format $ {}
                        :id $ .unwrap $ get code-data :id
                        :format result
                      , &unit
              []
                effect-render-code code $ .unwrap-or (get code-data :barcode-format) nil
                div
                  {} $ :style ui/center
                  div ({})
                    img $ {}
                  .render code-menu-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] (:: 'Map 'Dynamic 'Dynamic) 'String $ :: 'Map 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'effect-render-code $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-render-code (code format) (action el)
            when
              or (= action :mount) (= action :update)
              match
                browser/element-query-selector (browser/element-host el) |img
                (:none) &unit
                (:some image)
                  try
                    jsbarcode image code $ to-js-data $ merge
                      {} $ :displayValue false
                      match format
                        :gs1-128 $ {} (:format |CODE128) (:ean128 true)
                        :code-128 $ {} $ :format |CODE128
                        _ $ {} $ :format |CODE128
                    fn (error) (js/console.error error) (browser/element-set-attribute! image |src |) (browser/element-set-attribute! image |alt |Failed-to-render)
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ [] 'String 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.barcode
          :require
            respo-ui.core :refer $ hsl
            respo-ui.core :as ui
            respo.core :refer $ defcomp defeffect >> <> div button textarea span input img
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            |qrcode :as qrcode
            |jsbarcode :default jsbarcode
            respo-alerts.core :refer $ use-modal-menu comp-modal-menu
            js-ffi.browser :as browser
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-container (reel)
            let
                store $ :store reel
                states $ decode-map-as
                  .unwrap $ get store :states
                  :: 'Map 'Tag 'Dynamic
                remove-plugin $ use-confirm (>> states :remove)
                  {} $ :text "|Are use sure to remove?"
                create-plugin $ use-prompt (>> states :create)
                  {}
                    :input-style $ {} $ :font-family ui/font-code
                    :text "|Add new code"
                    :button-text |Render
              [] (effect-layout)
                div
                  {} $ :style $ merge ui/global ui/fullscreen ui/column
                  if
                    non-nil? $ .unwrap-or (get store :pointer) nil
                    div
                      {} $ :style $ merge ui/expand ui/column
                      div
                        {} $ :style $ merge ui/row-parted
                          {} $ :padding 8
                        span $ {}
                        comp-icon |arrow-up
                          {} (:font-size 20)
                            :color $ hsl 200 80 80
                            :cursor :pointer
                          fn (e d!)
                            hint-fn $ {}
                              :args $ [] 'Dynamic $ :: 'Fn
                                {}
                                  :args $ [] 'Enum
                                  :return 'Unit
                              :return 'Unit
                            d! $ :: :touch-code $ .unwrap-or (get store :pointer) nil
                            scroll-first!
                            , &unit
                      let
                          code-data $ decode-map-as
                            .unwrap-or
                              get-in store $ [] :codes $ .unwrap-or (get store :pointer) nil
                              , nil
                            :: 'Map 'Tag 'Dynamic
                          code $ decode-map-as
                            .unwrap $ get code-data :code
                            , 'String
                        div
                          {} $ :style $ merge ui/expand ui/center
                          div
                            {} $ :style ui/row-middle
                            <> code $ {} (:font-size 20) (:font-family ui/font-code)
                            =< 8 nil
                            comp-icon |toggle-right
                              {} (:size 20)
                                :color $ hsl 0 0 80
                                :font-size 20
                                :cursor :pointer
                              fn (e d!)
                                hint-fn $ {}
                                  :args $ [] 'Dynamic $ :: 'Fn
                                    {}
                                      :args $ [] 'Enum
                                      :return 'Unit
                                  :return 'Unit
                                d! $ :: :toggle-barcode $ .unwrap (get code-data :id)
                                , &unit
                          if
                            .unwrap-or (get code-data :barcode?) false
                            comp-barcode (>> states :barcode) code code-data
                            comp-qrcode code
                          comp-note (>> states :note) code-data
                      div
                        {} $ :style $ merge ui/row-parted
                          {} $ :padding 16
                        span $ {}
                        span
                          {} $ :on-click $ fn (e d!)
                            hint-fn $ {}
                              :args $ [] 'Dynamic $ :: 'Fn
                                {}
                                  :args $ [] 'Enum
                                  :return 'Unit
                              :return 'Unit
                            .show remove-plugin d! $ fn ()
                              d! $ :: :remove-code $ .unwrap-or (get store :pointer) nil
                              let
                                  new-pointer $ match
                                    first $ &set:to-list $ keys
                                      let
                                          codes $ schema/read-codes store
                                          pointer $ .unwrap-or (get store :pointer) nil
                                        if (string? pointer) (.dissoc codes pointer) codes
                                    (:some id) id
                                    (:none) nil
                                d! $ :: :pointer new-pointer
                            , &unit
                          comp-i |x-circle 20 $ hsl 0 80 70
                    div
                      {} $ :style $ merge ui/expand ui/center
                        {} (:font-family ui/font-fancy) (:font-size 24)
                          :color $ hsl 0 0 80
                      <> "|No selection"
                  comp-sidebar states store
                  div
                    {} $ :style $ merge ui/center
                      {} (:padding 16) (:margin :auto)
                    span
                      {}
                        :style $ {} $ :cursor :pointer
                        :on-click $ fn (e d!)
                          hint-fn $ {}
                            :args $ [] 'Dynamic $ :: 'Fn
                              {}
                                :args $ [] 'Enum
                                :return 'Unit
                            :return 'Unit
                          .show create-plugin d! $ fn (raw)
                            let
                                result $ decode-map-as raw 'String
                              when-not (blank? result)
                                d! $ :: :add-code result
                              , &unit
                          , &unit
                      comp-i |plus-square 28 $ hsl 200 80 80
                  .render remove-plugin
                  .render create-plugin
                  when dev? $ comp-typed-reel (>> states :reel) reel $ {}
                  when dev? $ comp-inspect |store store $ {} (:bottom 0)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] $ :: 'reel.typed/State 'Enum (:: 'Map 'Dynamic 'Dynamic)
            :features $ #{} :js-ffi
        'comp-note $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-note (states code)
            let
                note-plugin $ use-prompt (>> states :create)
                  {} (:text "|Some note:") (:button-text |Add)
                    :initial $ decode-map-as
                      or
                        .unwrap-or (get code :note) nil
                        , |
                      , 'String
              div
                {} $ :style ui/row-middle
                <>
                  decode-map-as
                    or
                      .unwrap-or (get code :note) nil
                      , |...
                    , 'String
                  {} $ :color $ hsl 0 0 70
                =< 8 nil
                span
                  {}
                    :style $ {} $ :cursor :pointer
                    :on-click $ fn (e d!)
                      hint-fn $ {}
                        :args $ [] 'Dynamic $ :: 'Fn
                          {}
                            :args $ [] 'Enum
                            :return 'Unit
                        :return 'Unit
                      .show note-plugin d! $ fn (raw)
                        let
                            result $ decode-map-as raw 'String
                            id $ decode-map-as
                              .unwrap $ get code :id
                              , 'String
                          d! $ :: :note-code $ if (blank? result)
                            {} $ :id id
                            {} (:id id) (:note result)
                      , &unit
                  comp-i |edit 14 $ hsl 0 0 80
                .render note-plugin
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] (:: 'Map 'Dynamic 'Dynamic) (:: 'Map 'Dynamic 'Dynamic)
            :features $ #{} :js-ffi
        'comp-sidebar $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-sidebar (states store)
            div
              {} $ :style $ merge ui/expand
                {}
                  :background-color $ hsl 0 0 96
                  :display :flex
                  :padding "|10px 60px"
              list->
                {}
                  :style $ merge $ {} (:margin :auto) (:white-space :nowrap)
                  :class-name |scroll-area
                -> (schema/read-codes store) distinct-values .to-list
                  .sort-by $ fn (code)
                    - 0 $ decode-map-as
                      .unwrap $ get code :time
                      , 'Number
                  .map $ fn (code)
                    []
                      decode-map-as
                        .unwrap $ get code :id
                        , 'String
                      div
                        {}
                          :style $ if
                            =
                              decode-map-as
                                .unwrap $ get code :id
                                , 'String
                              .unwrap-or (get store :pointer) nil
                            assoc style-card :background-color :white
                            , style-card
                          :on-click $ fn (e d!)
                            hint-fn $ {}
                              :args $ [] 'Dynamic $ :: 'Fn
                                {}
                                  :args $ [] 'Enum
                                  :return 'Unit
                              :return 'Unit
                            d! $ :: :pointer $ decode-map-as
                              .unwrap $ get code :id
                              , 'String
                            , &unit
                        div ({})
                          <>
                            decode-map-as
                              .unwrap $ get code :code
                              , 'String
                            {} (:font-size 16) (:line-height |40px) (:display :inline-block)
                        div ({})
                          <>
                            decode-map-as
                              or
                                .unwrap-or (get code :note) nil
                                , |
                              , 'String
                            {}
                              :color $ hsl 0 0 80
                              :font-family ui/font-normal
                              :font-size 12
                        div ({})
                          if
                            .unwrap-or (get code :barcode?) false
                            comp-i |bar-chart 16 $ hsl 0 0 0
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] (:: 'Map 'Dynamic 'Dynamic) (:: 'Map 'Dynamic 'Dynamic)
            :features $ #{} :js-ffi
        'effect-layout $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-layout () (action el) &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ []
            :features $ #{} :js-ffi
        'scroll-first! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn scroll-first! ()
            match (browser/query-selector |.scroll-area>:first-child)
              (:some element)
                .!scrollIntoView element $ js-object (:behavior |smooth) (:block |nearest) (:inline |nearest)
              (:none) &unit
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'style-card $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def style-card
            {} (:padding "|12px 12px") (:font-size 18) (:font-family ui/font-code) (:cursor :pointer)
              :border-bottom $ str "|1px solid " $ hsl 0 0 88
              :text-overflow :ellipsis
              :overflow :hidden
              :min-width 60
              :height 120
              :display :inline-block
          :examples $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
            respo-ui.core :refer $ hsl
            respo-ui.core :as ui
            respo.core :refer $ defcomp defeffect >> list-> <> div button textarea span input
            respo.comp.space :refer $ =<
            respo.comp.inspect :refer $ comp-inspect
            reel.comp.reel :refer $ comp-typed-reel
            app.config :refer $ dev?
            app.comp.qrcode :refer $ comp-qrcode
            app.comp.barcode :refer $ comp-barcode
            |qrcode :as qrcode
            feather.core :refer $ comp-icon comp-i
            respo-alerts.core :refer $ use-prompt use-confirm
            js-ffi.browser :as browser
            app.schema :as schema
    'app.comp.qrcode $ %{} 'FileEntry
      :defs $ {}
        'comp-qrcode $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-qrcode (code)
            [] (effect-render-code code)
              div ({})
                img $ {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Component)
            :args $ [] 'String
            :features $ #{} :js-ffi
        'effect-render-code $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-render-code (code) (action el)
            when
              or (= action :mount) (= action :update)
              match
                browser/element-query-selector (browser/element-host el) |img
                (:none) &unit
                (:some image)
                  let
                      promise $ contract/expect-object |qrcode-promise $ qrcode/toDataURL code
                    shared/promise-observe! promise
                      fn (url)
                        browser/element-set-attribute! image |src $ contract/expect-string |qrcode-url url
                      fn (error) (js/console.error error) (browser/element-set-attribute! image |alt |Failed-to-render)
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.schema/Effect)
            :args $ [] 'String
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.qrcode
          :require
            respo-ui.core :refer $ hsl
            respo-ui.core :as ui
            respo.core :refer $ defcomp defeffect <> div button textarea span input img
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            |qrcode :as qrcode
            js-ffi.browser :as browser
            js-ffi.contract :as contract
            js-ffi.shared :as shared
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ .unwrap-or (get-env |mode) |release
          :examples $ []
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:dev-ui |http://localhost:8100/main-fonts.css) (:release-ui |http://cdn.tiye.me/favored-fonts/main-fonts.css) (:cdn-url |http://cdn.tiye.me/qrcode-shelf/) (:title "|QR Code") (:icon |http://cdn.tiye.me/logo/qrcode-shelf.png) (:storage-key |qrcode-shelf)
          :examples $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel (typed/new-reel schema/store)
          :examples $ []
          :schema $ :: 'Ref $ :: 'reel.typed/State 'Enum (:: 'Map 'Dynamic 'Dynamic)
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            if (enum? op)
              do
                when config/dev? $ println |Dispatch: op
                reset! *reel $ typed/record-op updater @*reel op (generate-id!) (shared/now-ms)
                , &unit
              raise "|Expected an Enum operation"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Enum
            :features $ #{} :js-ffi
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (println |Running-mode: config/dev?)
            when config/dev? $ load-console-formatter!
            match
              browser/storage-get $ .unwrap $ get config/site :storage-key
              (:some raw)
                match (try-parse-cirru-edn raw)
                  (:ok data)
                    match
                      try-decode-map-as data $ :: 'Map 'Tag 'Dynamic
                      (:ok saved)
                        dispatch! $ :: :hydrate-storage saved
                      (:err _)
                        raise "|QRcode Shelf storage must be a Map<Tag, Dynamic>; original data retained and automatic saving not started."
                  (:err _)
                    raise "|Unable to parse QRcode Shelf storage; original data retained and automatic saving not started."
              (:none) &unit
            render-app!
            add-watch! *reel :changes $ fn (s p) (render-app!)
            listen-devtools! |a dispatch!
            browser/set-before-unload! $ fn (e) (persist-storage!)
            browser/set-interval! persist-storage! 60000
            println |App-started.
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn mount-target ()
            .unwrap $ respo-browser/query-selector |.app
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'respo.dom/DomElement)
            :args $ []
            :features $ #{} :js-ffi
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            browser/storage-set!
              .unwrap $ get config/site :storage-key
              format-cirru-edn $ :store @*reel
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (clear-cache!)
            reset! *reel $ typed/refresh updater @*reel schema/store
            println |Code-updated.
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render-with! (mount-target)
              fn () $ comp-container @*reel
              , dispatch!
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'snippets $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn snippets () (println config/site)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            respo.core :refer $ render-with! clear-cache!
            app.comp.container :refer $ comp-container
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.typed :as typed
            app.config :as config
            js-ffi.browser :as browser
            js-ffi.shared :as shared
            respo.ffi.browser :as respo-browser
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'Op $ %{} 'CodeEntry
          :doc "|Dispatch Op of QRCode Shelf, bound to the :dispatch-op type slot. Includes the :reel/* controls that comp-reel sends."
          :code $ quote $ defenum Op
            :states (:: 'List 'Dynamic) 'Dynamic
            :content 'Dynamic
            :hydrate-storage 'Dynamic
            :add-code 'Dynamic
            :touch-code 'Dynamic
            :pointer 'Dynamic
            :remove-code 'Dynamic
            :note-code 'Dynamic
            :code-format 'Dynamic
            :toggle-barcode 'Dynamic
            :reel/toggle
            :reel/recall 'Number
            :reel/run
            :reel/step
            :reel/merge
            :reel/reset
            :reel/remove 'Number
          :examples $ []
          :schema $ :: 'EnumDef
        'code $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def code
            {} (:id nil) (:code nil) (:note nil) (:timestamp nil) (:barcode? false) (:barcode-format nil)
          :examples $ []
        'read-codes $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-codes (store)
            decode-map-as
              .unwrap $ get store :codes
              :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] $ :: 'Map 'Dynamic 'Dynamic
            :return $ :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            {}
              :states $ {} $ :cursor ([])
              :codes $ {}
              :pointer nil
          :examples $ []
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {} $ 'updater
        %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            decode-map-as
              match op
                (:states cursor state)
                  update-states store
                    decode-map-as cursor $ :: 'List 'Dynamic
                    , state
                (:content value) (assoc store :content value)
                (:hydrate-storage value) value
                (:add-code value)
                  -> store
                    assoc-in ([] :codes op-id)
                      merge schema/code $ {} (:id op-id) (:code value) (:time op-time)
                    assoc :pointer op-id
                (:touch-code id)
                  assoc-in store ([] :codes id :time) op-time
                (:pointer id) (assoc store :pointer id)
                (:remove-code id)
                  -> store
                    dissoc-in $ [] :codes id
                    assoc :pointer nil
                (:note-code data)
                  assoc-in store
                    [] :codes
                      .unwrap $ get data :id
                      , :note
                    .unwrap-or (get data :note) nil
                (:code-format data)
                  assoc-in store
                    [] :codes
                      .unwrap $ get data :id
                      , :barcode-format
                    .unwrap $ get data :format
                (:toggle-barcode id)
                  assoc-in store ([] :codes id :barcode?)
                    not $ .unwrap-or
                      get-in store $ [] :codes id :barcode?
                      , false
                _ $ do (println |Unknown-op: op) store
              :: 'Map 'Dynamic 'Dynamic
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'Dynamic 'Dynamic) 'Enum 'String 'Number
            :features $ #{} :js-ffi
            :return $ :: 'Map 'Dynamic 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require
            respo.cursor :refer $ update-states
            app.schema :as schema
