$(function() {
    var myid;
    
    var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));
    msgflag = false;

    //current trains sprite objects
    currentTrains = {};

    ws.onmessage = function(msg) {
        var data = JSON.parse(msg.data);
        console.log(data);
        if(!data.trains){return;}
        if(msgflag) {console.log(data)}
        //$(".trains").append("<p>" + msg.data + "</p>");
        var trains = data.trains;

        //処理フラグ
        for(var x in currentTrains) {
            currentTrains[x].proc = false;
        }

        for(i = 0; i < trains.length; ++i){
            var train;
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
    core.fps = 10;

    core.onload = function(){
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

    core.start(); // start your core!`
    $(".subway-map").subwayMap({ debug: true });
});

