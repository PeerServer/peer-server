ps -ef | grep coffee | grep wc | cut -f4 -d' ' | xargs kill
