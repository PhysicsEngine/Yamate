$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    msgflag = false;
    var win ;
    //current trains sprite objects
    currentTrains = {};

    ws.onmessage = function(msg) {
        var data = JSON.parse(msg.data);
        if(!data.trains){return;}
        if(msgflag) {console.log(data)}
        //$(".trains").append("<p>" + msg.data + "</p>");
        var trains = data.trains;
        //処理フラグ
        for(var x in currentTrains) {
            currentTrains[x].proc = false;
        }
        var winmsg = "";
        for(i = 0; i < trains.length; ++i){
            var train;
            winmsg += "train["+i+"]\n";
            var exists = currentTrains[trains[i].train_number]!=undefined;
            if(exists) {
                train = currentTrains[trains[i].train_number];
            }else{
                train = new Train();
                currentTrains[trains[i].train_number] = train;
            }
            train.proc = true;

            var x,y;
            if("inside_line" === trains[i].line_name){
                x = (trains[i].x + 1) * 281 + 41;
                y = (trains[i].y + 1) * 281 + 37;
            } else {
                x = (trains[i].x + 1) * 319 + 3;
                y = (trains[i].y + 1) * 319 + 0;
            }

            if(exists){
                train.x = x;
                train.y = y;
            }else{
                train.moveTo(x, y, 40);
                core.rootScene.addChild(train);
            }
            win.setText(winmsg,"fuga");

        }

        //処理flag==falseの要素を削除
        for(var x in currentTrains) {
            if(!currentTrains[x].proc) {
                core.rootScene.removeChild(currentTrains[x]);
                delete currentTrains[x];
            }
        }
    }

    enchant(); // initialize
    var core = new Core(680, 680); // core stage
    core.preload('./images/yamate.png'); // preload image
    core.preload('./images/fukidashi.jpg'); // preload image
    core.fps = 10;

    core.onload = function(){
       win = new MessageWindow(140,200);
       win.startAutoText();
       core.rootScene.addChild(win);

      /* 
        bear.tl.moveBy(288, 0, 90)   // move right
            .scaleTo(-1, 1, 10)      // turn left
            .moveBy(-288, 0, 90)     // move left
            .scaleTo(1, 1, 10)       // turn right
            .loop();                 // loop it
        */
    };

    // Train Object Class
    var defineFrame = [0, 1, 0, 2];
    var Train = Class.create(Sprite, {
        // 初期化
        initialize: function() {
            Sprite.call(this, 36, 36);
            this.image = core.assets['./images/yamate.png'];

            var rand = Math.floor( Math.random() * 100 ) % 4;
            var newFrame = [];
            for(var i=0;i<4;i++){
                newFrame.push(defineFrame[(i+rand)%4]);
            }
            //console.log(newFrame);
            this.frame = newFrame;   // select sprite frame
        }
    });

   var MessageWindow = Class.create( Group, {
    // コンストラクタ.
    initialize: function( x, y ) {
        enchant.Group.call( this );                         // 継承元をコール.
        this.x = x;                                         // メッセージウィンドウを表示するX座標.
        this.y = y;                                         // メッセージウィンドウを表示するY座標.
        this.texts=[];
        var bg = new Sprite( 400, 350 );                     // 幅と高さを設定.
        bg.image = core.assets[ './images/fukidashi.jpg' ];    // メッセージウィンドウの背景画像を設定.
        bg.x = 0;                                           // X座標(グループ内相対).
        bg.y = 0;                                           // Y座標(グループ内相対).
        this.addChild( bg );                                // グループに背景画像を追加.
 
        var line1 = new Label("テキスト１行目");           // メッセージ文字列を生成.
        line1.font = "10px PixelMplus10";                   // 文字サイズとWEBフォントの設定.
        line1.color = '#000000';                            // 文字色の設定.
        line1.x = 26;                                       // X座標(グループ内相対).
        line1.y = 10;                                       // Y座標(グループ内相対).
        line1.width = 400;                                  // 20文字分(20x20)の幅を確保.
        line1.textAlign = "left";                           // 左揃えに設定.
        this.addChild( line1 );                             // グループにメッセージ文字列を追加.
 
        var line2 = new Label("テキスト２行目");           // メッセージ文字列を生成.
        line2.font = "10px PixelMplus10";                   // 文字サイズとWEBフォントの設定.
        line2.color = '#000000';                            // 文字色の設定.
        line2.x = 26;                                       // X座標(グループ内相対).
        line2.y = 34;                                       // Y座標(グループ内相対).
        line2.width = 400;                                  // 20文字分(20x20)の幅を確保.
        line2.textAlign = "left";                           // 左揃えに設定.
        this.addChild( line2 );                             // グループにメッセージ文字列を追加.
 
        this.autoText = new Array();                        // 自動送り用メッセージを格納しておく配列.
    },
    setText: function( text1, text2 ) {
        this.childNodes[ 1 ].text = text1;                  // メッセージ文字列の更新.
        this.childNodes[ 2 ].text = text2;                  // メッセージ文字列の更新.
    },
    setAutoText: function( text1, text2 ) {
        this.autoText.push( [ text1, text2 ] );             // 自動送り用メッセージに登録.
    },
    startAutoText: function() {
        this._showAutoText( this );                         // 自動送り用メッセージの表示.
    },
    _showAutoText: function( me ) {
        if ( 0 == me.autoText.length ) {                    // 自動送り用メッセージが無くなったら終了.
            return;
        }
        var at = me.autoText.shift();                       // 自動送り用メッセージの取得.
        me.childNodes[ 1 ].text = me.childNodes[2].text;;                  // メッセージ文字列の更新.
        me.childNodes[ 2 ].text = at;                  // メッセージ文字列の更新.
        setTimeout( me._showAutoText, 100, me );            // 400msでメッセージを自動送り.
    }
});
 


    core.start(); // start your core!`
    $(".subway-map").subwayMap({ debug: true });
});

