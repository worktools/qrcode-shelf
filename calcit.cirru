
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |reel.calcit/ |alerts.calcit/ |js-ffi/ |respo-feather.calcit/
      :type-slots $ {} $ :dispatch-op 'app.schema/Op
  :files $ {}
    'app.comp.barcode $ %{} 'FileEntry
      :defs $ {}
        'barcodes-list $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def barcodes-list
            [] (app.schema/BarcodeFormat :code-128) (app.schema/BarcodeFormat :gs1-128)
          :examples $ []
          :schema $ quote $ List app.schema/BarcodeFormat
        'comp-barcode $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-barcode (states code code-data)
            let
                code-menu-plugin $ use-modal-menu (>> states :codes)
                  {} (:title |Demo)
                    :style $ {} $ :width 300
                    :backdrop-style $ {}
                    :items $ .map barcodes-list $ fn (format)
                      match format
                        (:code-128) (app.schema/BarcodeMenuItem :item :code-128 |CODE128)
                        (:gs1-128) (app.schema/BarcodeMenuItem :item :gs1-128 |GS1-128)
                    :on-result $ fn (result d!)
                      hint-fn $ Fn Dynamic
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      match (try-decode-map-as result app.schema/BarcodeMenuItem)
                        (:ok item)
                          match item $
                            :item selected _
                            d! $ app.schema/Op :code-format (code-data :id) (app.schema/decode-barcode-format selected)
                        (:err _) &unit
                      , &unit
              []
                effect-render-code code $ code-data :format
                div
                  {} $ :style ui/center
                  div ({})
                    img $ {}
                  .render code-menu-plugin
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) String app.schema/CodeView (-> respo.schema/Component) (:features :js-ffi)
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
                        (:gs1-128)
                          {} (:format |CODE128) (:ean128 true)
                        (:code-128)
                          {} $ :format |CODE128
                    fn (error) (js/console.error error) (browser/element-set-attribute! image |src |) (browser/element-set-attribute! image |alt |Failed-to-render)
            , &unit
          :examples $ []
          :schema $ quote $ Fn String app.schema/BarcodeFormat (-> respo.schema/Effect) (:features :js-ffi)
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
          :code $ quote $ defcomp comp-container (reel on-control)
            let
                store $ :store reel
                states $ decode-map-as
                  .unwrap $ get store :states
                  Map Tag Dynamic
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
                    match (get store :pointer)
                      (:some pointer) (non-nil? pointer)
                      (:none) false
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
                            hint-fn $ Fn respo.schema/RespoEvent
                              Fn schema/Op $ -> Unit
                              -> Unit
                            d! $ :: :touch-code $ decode-map-as
                              .unwrap-or (get store :pointer) |
                              , String
                            scroll-first!
                            , &unit
                      let
                          code-data $ app.schema/read-code-view $ .unwrap-or
                            get-in store $ [] :codes $ .unwrap-or (get store :pointer) |
                            , nil
                          code $ code-data :code
                        div
                          {} $ :style $ merge ui/expand ui/center
                          div
                            {} $ :style ui/row-middle
                            <> code $ {} (:font-size 20) (:font-family ui/font-code)
                            space-x 8
                            comp-icon |toggle-right
                              {} (:size 20)
                                :color $ hsl 0 0 80
                                :font-size 20
                                :cursor :pointer
                              fn (e d!)
                                hint-fn $ Fn respo.schema/RespoEvent
                                  Fn schema/Op $ -> Unit
                                  -> Unit
                                d! $ :: :toggle-barcode $ code-data :id
                                , &unit
                          if (code-data :barcode?)
                            comp-barcode (>> states :barcode) code code-data
                            comp-qrcode code
                          comp-note (>> states :note) code-data
                      div
                        {} $ :style $ merge ui/row-parted
                          {} $ :padding 16
                        span $ {}
                        span
                          {} $ :on-click $ fn (e d!)
                            hint-fn $ Fn respo.schema/RespoEvent
                              Fn schema/Op $ -> Unit
                              -> Unit
                            .show remove-plugin d! $ fn ()
                              d! $ :: :remove-code $ decode-map-as
                                .unwrap-or (get store :pointer) |
                                , String
                              match
                                first $ .to-list $ keys
                                  let
                                      codes $ schema/read-codes $ .unwrap (get store :codes)
                                      pointer $ .unwrap-or (get store :pointer) |
                                    if (string? pointer) (.dissoc codes pointer) codes
                                (:some id)
                                  d! $ :: :pointer id
                                (:none) &unit
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
                          hint-fn $ Fn respo.schema/RespoEvent
                            Fn schema/Op $ -> Unit
                            -> Unit
                          .show create-plugin d! $ fn (result)
                            hint-fn $ Fn String $ -> Unit
                            when-not (blank? result)
                              d! $ :: :add-code result
                            , &unit
                          , &unit
                      comp-i |plus-square 28 $ hsl 200 80 80
                  .render remove-plugin
                  .render create-plugin
                  if dev?
                    Some $ comp-typed-reel (>> states :reel) reel ({}) on-control
                    , None
                  if dev?
                    Some $ comp-inspect |store store $ {} (:bottom 0)
                    , None
          :examples $ []
          :schema $ quote $ Fn
            reel.typed/State schema/Op $ Map Dynamic Dynamic
            Fn reel.typed/Control $ -> Unit
            -> respo.schema/Component
            :features :js-ffi
        'comp-note $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defcomp comp-note (states code)
            let
                note-plugin $ use-prompt (>> states :create)
                  {} (:text "|Some note:") (:button-text |Add)
                    :initial $ .unwrap-or (code :note) |
              div
                {} $ :style ui/row-middle
                <>
                  .unwrap-or (code :note) |...
                  {} $ :color $ hsl 0 0 70
                space-x 8
                span
                  {}
                    :style $ {} $ :cursor :pointer
                    :on-click $ fn (e d!)
                      hint-fn $ Fn respo.schema/RespoEvent
                        Fn schema/Op $ -> Unit
                        -> Unit
                      .show note-plugin d! $ fn (result)
                        hint-fn $ Fn String $ -> Unit
                        let
                            id $ code :id
                          d! $ :: :note-code id $ if (blank? result) None (Some result)
                      , &unit
                  comp-i |edit 14 $ hsl 0 0 80
                .render note-plugin
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) schema/CodeView (-> respo.schema/Component) (:features :js-ffi)
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
                ->
                  schema/read-codes $ .unwrap $ get store :codes
                  , distinct-values .to-list (.map schema/read-code-view)
                    .sort-by $ fn (code)
                      - 0 $ code :time
                    .map $ fn (code)
                      [] (code :id)
                        div
                          {}
                            :style $ if
                              = (code :id)
                                .unwrap-or (get store :pointer) |
                              assoc style-card :background-color :white
                              , style-card
                            :on-click $ fn (e d!)
                              hint-fn $ Fn respo.schema/RespoEvent
                                Fn schema/Op $ -> Unit
                                -> Unit
                              d! $ :: :pointer $ code :id
                              , &unit
                          div ({})
                            <> (code :code)
                              {} (:font-size 16) (:line-height |40px) (:display :inline-block)
                          div ({})
                            <>
                              .unwrap-or (code :note) |
                              {}
                                :color $ hsl 0 0 80
                                :font-family ui/font-normal
                                :font-size 12
                          div ({})
                            if (code :barcode?)
                              Some $ comp-i |bar-chart 16 $ hsl 0 0 0
                              , None
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) (Map Dynamic Dynamic) (-> respo.schema/Component) (:features :js-ffi)
        'effect-layout $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defeffect effect-layout () (action el) &unit
          :examples $ []
          :schema $ quote $ Fn (-> respo.schema/Effect) (:features :js-ffi)
        'scroll-first! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn scroll-first! ()
            match (browser/query-selector |.scroll-area>:first-child)
              (:some element)
                .!scrollIntoView element $ js-object (:behavior |smooth) (:block |nearest) (:inline |nearest)
              (:none) &unit
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
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
          :schema $ quote $ Map Tag respo-ui.schema/StyleValue
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
            respo-ui.core :refer $ hsl
            respo-ui.core :as ui
            respo.core :refer $ defcomp defeffect >> list-> <> div button textarea span input
            respo.comp.space :refer $ space-x
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
          :schema $ quote $ Fn String (-> respo.schema/Component) (:features :js-ffi)
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
          :schema $ quote $ Fn String (-> respo.schema/Effect) (:features :js-ffi)
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
          :schema $ quote Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:dev-ui |http://localhost:8100/main-fonts.css) (:release-ui |http://cdn.tiye.me/favored-fonts/main-fonts.css) (:cdn-url |http://cdn.tiye.me/qrcode-shelf/) (:title "|QR Code") (:icon |http://cdn.tiye.me/logo/qrcode-shelf.png) (:storage-key |qrcode-shelf)
          :examples $ []
          :schema $ quote $ Map Tag String
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*reel $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *reel (typed/new-reel schema/store)
          :examples $ []
          :schema $ quote $ Ref
            typed/State schema/Op $ Map Dynamic Dynamic
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when config/dev? $ println |Dispatch: op
            reset! *reel $ typed/record-op updater @*reel op (generate-id!) (shared/now-ms)
            , &unit
          :examples $ []
          :schema $ quote $ Fn schema/Op (-> Unit) (:features :io :js-ffi :state)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (println |Running-mode: config/dev?)
            when config/dev? $ load-console-formatter!
            match
              browser/storage-get $ .unwrap $ get config/site :storage-key
              (:some raw)
                match (try-parse-cirru-edn raw)
                  (:ok data)
                    match
                      try-decode-map-as data $ Map Tag Dynamic
                      (:ok saved)
                        dispatch! $ :: :hydrate-storage saved
                      (:err _)
                        raise "|QRcode Shelf storage must be a Map<Tag, Dynamic>; original data retained and automatic saving not started."
                  (:err _)
                    raise "|Unable to parse QRcode Shelf storage; original data retained and automatic saving not started."
              (:none) &unit
            render-app!
            add-watch! *reel :changes $ fn (s p) (render-app!)
            listen-devtools! |a on-control!
            browser/set-before-unload! $ fn (e) (persist-storage!)
            browser/set-interval! persist-storage! 60000
            println |App-started.
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi :state)
        'mount-target $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn mount-target ()
            .unwrap $ respo-browser/query-selector |.app
          :examples $ []
          :schema $ quote $ Fn (-> respo.dom/DomElement) (:features :js-ffi)
        'on-control! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn on-control! (control)
            reset! *reel $ typed/apply-control updater @*reel control
            , &unit
          :examples $ []
          :schema $ quote $ Fn typed/Control (-> Unit) (:features :io :state)
        'persist-storage! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn persist-storage! ()
            browser/storage-set!
              .unwrap $ get config/site :storage-key
              format-cirru-edn $ :store @*reel
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi :state)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (clear-cache!)
            reset! *reel $ typed/refresh updater @*reel schema/store
            println |Code-updated.
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi :state)
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! ()
            render-with! (mount-target)
              fn () $ comp-container @*reel on-control!
              , dispatch!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi :state)
        'snippets $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn snippets () (println config/site)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io)
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
        'BarcodeFormat $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum BarcodeFormat (:code-128) (:gs1-128)
          :examples $ []
          :schema $ quote EnumDef
        'BarcodeMenuItem $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum BarcodeMenuItem (:item Tag String)
          :examples $ []
          :schema $ quote EnumDef
        'CodeView $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct CodeView (:id String) (:code String) (:time Number)
            :note $ Option String
            :barcode? Bool
            :format app.schema/BarcodeFormat
          :examples $ []
          :schema $ quote StructDef
        'Op $ %{} 'CodeEntry
          :doc "|Dispatch Op of QRCode Shelf, bound to the :dispatch-op type slot. Reel Control is delivered through its own callback."
          :code $ quote $ defenum Op
            :states (List respo.schema/CoordKey) StateValue
            :hydrate-storage $ Map Tag Dynamic
            :add-code String
            :touch-code String
            :pointer String
            :remove-code String
            :note-code String $ Option String
            :code-format String app.schema/BarcodeFormat
            :toggle-barcode String
          :examples $ []
          :schema $ quote EnumDef
        'StateValue $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defunion StateValue Bool Number String Tag (List StateValue) (Map respo.schema/CoordKey StateValue)
          :examples $ []
          :schema $ quote UnionDef
        'code $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def code
            {} (:id nil) (:code nil) (:note nil) (:timestamp nil) (:barcode? false) (:barcode-format nil)
          :examples $ []
        'decode-barcode-format $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-barcode-format (raw)
            if
              and (tag? raw)
                = :gs1-128 $ decode-map-as raw 'Tag
              app.schema/BarcodeFormat :gs1-128
              app.schema/BarcodeFormat :code-128
          :examples $ []
          :schema $ quote $ Fn Input (-> BarcodeFormat) (:generics Input)
        'read-code-view $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-code-view (raw)
            let
                fields $ decode-map-as raw $ Map Tag Dynamic
                note $ .and-then (get fields :note)
                  fn (value)
                    if value
                      Some $ decode-map-as value String
                      , None
              CodeView :id
                decode-map-as
                  .unwrap $ get fields :id
                  , String
                , :code
                  decode-map-as
                    .unwrap $ get fields :code
                    , String
                  , :time
                    decode-map-as
                      .unwrap $ get fields :time
                      , Number
                    , :note note :barcode?
                      if
                        .unwrap-or (get fields :barcode?) false
                        , true false
                      , :format $ decode-barcode-format $ .unwrap-or (get fields :barcode-format) :code-128
          :examples $ []
          :schema $ quote $ Fn Input (-> CodeView) (:generics Input)
        'read-codes $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn read-codes (raw)
            decode-map-as raw $ Map String $ Map Tag Dynamic
          :examples $ []
          :schema $ quote $ Fn Input
            -> $ Map String $ Map Tag Dynamic
            :generics Input
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
                (:states cursor state) (update-states store cursor state)
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
                (:note-code id note)
                  match note
                    (:some text)
                      assoc-in store ([] :codes id :note) text
                    (:none)
                      assoc-in store ([] :codes id :note) nil
                (:code-format id format)
                  assoc-in store ([] :codes id :barcode-format)
                    match format
                      (:code-128) :code-128
                      (:gs1-128) :gs1-128
                (:toggle-barcode id)
                  assoc-in store ([] :codes id :barcode?)
                    not $ .unwrap-or
                      get-in store $ [] :codes id :barcode?
                      , false
                _ $ do (println |Unknown-op: op) store
              Map Dynamic Dynamic
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) schema/Op String Number
            -> $ Map Dynamic Dynamic
            :features :io :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require
            respo.cursor :refer $ update-states
            app.schema :as schema
