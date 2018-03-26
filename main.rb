#!mruby
SSID = "ssssss"
PASS = "pppppp"
SERVER = "xxxxxx.firebaseio.com/word.json?auth=aaaaaa"
OUTPUT_PIN = 17             # 制御するピンの番号

if (System.useSD() == 0) then
    puts "SD Card can't use."
    System.exit()
end

if (System.useWiFi() == 0) then
    puts "WiFi Card can't use."
    System.exit()
end

puts "setup wifi"
puts WiFi.version
WiFi.disconnect
WiFi.setMode 1  #Station-Mode
WiFi.connect(SSID, PASS)
puts WiFi.ipconfig
WiFi.multiConnect 1

GC.start
delay 0

pinMode(OUTPUT_PIN, OUTPUT)

previous_result = ""    # 前回の取得結果
result = ""             # 今回の取得結果
previous_char = 0       # 最後の文字

loop do
    # クラウドに接続してデータを取得し、SDカードに結果を保存する
    unless WiFi.httpsGetSD("response.txt", SERVER) == 1 then
        puts "https get error."
        delay 60000
    end

    # SDカードに保存した結果から、ヘッダの行を読み飛ばして最後の行（HTTP Body）だけを取得する
    SD.open 0, "response.txt", 0
    while (c = SD.read(0)) > 0
        result = "" if (previous_char == 0x0A)  # 新しい行が始まったら行バッファをクリア
        result << c.chr
        previous_char = c
    end
    SD.close(0)

    # 前回の取得結果と今回の取得結果が異なる場合のみ処理をする
    unless previous_result == result then
        puts result
        previous_result = result.dup

        digitalWrite(OUTPUT_PIN, 1) if result.start_with?('"ON')  # 取得結果が "ON から始まる -> LEDをつける
        digitalWrite(OUTPUT_PIN, 0) if result.start_with?('"OFF') # 取得結果が "OFF から始まる -> LEDを消す
    end

    # 一定時間待ってから再度クラウドからデータを取得する
    delay 500
end

puts "WiFi disconnect"
WiFi.disconnect
