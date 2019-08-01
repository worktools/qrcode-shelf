
(ns app.schema )

(def code {:id nil, :code nil, :timestamp nil})

(def store {:states {}, :codes (do code {}), :pointer nil, :code-url nil})
