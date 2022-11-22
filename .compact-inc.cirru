
{}
  :added $ {}
  :changed $ {}
    |app.comp.container $ {}
      :added-defs $ {}
      :changed-defs $ {}
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
      :removed-defs $ #{}
  :removed $ #{}
