/** BoidsDrawクラス（ボイドの描画に関するクラス）**/
class BoidsDraw {

  Boid[] b; //ボイドの配列
  int pop;  //ボイドの総数（コンストラクタで指定）
  int count = 0;

  float trace_width = 0.5;  //ボイドの軌跡の線幅

  PGraphics pg_body;  //ボイドの描画レイヤ
  PGraphics pg_trace; //移動軌跡の描画レイヤ
  PGraphics pg_connect;
  PGraphics pg_cluster;

  boolean MODE_RULE1 = false; //ルール1の適用の有無
  boolean MODE_RULE2 = false; //ルール2の適用の有無
  boolean MODE_RULE3 = false; //ルール3の適用の有無
  boolean MODE_RULE4 = false; //ルール４
  boolean MODE_RULE5 = false; //ルール5
  boolean MODE_ATTRACT = true;  //マウスを押した際の作用（true：引力, false：斥力）

  /*
	float c1 = 0.1; 	//ルール1の係数
   	float c2 = 5.0; 	//ルール2の係数
   	float c3 = 0.05;	//ルール3の係数
   	*/

  /** コンストラクタ **/
  //引数（p：ボイドの総数, w：画面の幅, h：画面の高さ）
  BoidsDraw(int p, int w, int h) {

    this.pop = p; //個体数をフィールドに代入

    //ボイドの配列を初期化
    b = new Boid[pop];

    //ボイドをpop分だけ生成したのち, 初期化
    //（位置と速度をランダムに与える）
    for (int i=0; i<pop; i++) {
      b[i] = new Boid();
    }

    //描画用のレイヤの生成
    pg_body = createGraphics(w, h, JAVA2D);
    pg_trace = createGraphics(w, h, JAVA2D);
    pg_connect = createGraphics(w, h, JAVA2D);
    pg_cluster = createGraphics(w, h, JAVA2D);
  }

  /** メソッド **/

  //初期化（位置と速度をシャッフル）
  void init() {
    for (int i=0; i<pop; i++) {
      b[i].init();
    }
  }

  //位置の更新
  void updCondition() {

    //ボイドのルールの適用
    if (MODE_RULE1) 	applyRule1();
    if (MODE_RULE2)	applyRule2();
    if (MODE_RULE3)	applyRule3();
    if (MODE_RULE4)  applyRule4();
    if (MODE_RULE5)  applyRule5();

    //マウスが押されたときの作用
    if (mousePressed) {
      if (MODE_ATTRACT) {
        ruleAttractor(); //引力の発生
      } else {
        ruleSeparator(); //斥力の発生
      }
    }		

    //全てのボイドの位置を更新します. 
    for (int i=0; i<pop; i++) {
      b[i].upd();
    }
  }

  //ボイドをレイヤに描画（本画面に出力されないことに注意）
  void drawBoidsLayer() {
    drawBodyLayer();	//ボイドレイヤの描画
    drawTraceLayer(); 	//トレース・レイヤの描画
    drawConnectLayer();
    drawClusterLayer();
  }


  //　ボイドレイヤの描画（ボイドの本体）
  void drawBodyLayer() {

    pg_body.beginDraw();//描画の開始

    //描画ここから---------------------------
    pg_body.clear();	//画面をクリア
    pg_body.noStroke(); //線を描かない

    for (int i=0; i<pop; i++) {
      //色の設定
      pg_body.noFill();
      pg_body.stroke(b[i].color_r + b[i].r + b[i].r2, b[i].color_g + b[i].g, b[i].color_b + b[i].b, 200);
      //i番目のボイドのx座標・y座標
      float ix = b[i].pos.x; 
      float iy = b[i].pos.y; 
      //円の描画
      pg_body.ellipse(ix, iy, b[i].body_size, b[i].body_size);
    }
    //描画ここまで---------------------------

    pg_body.endDraw(); //描画の終了
  }

  //　トレースレイヤの描画（ボイドの軌跡）
  void drawTraceLayer() {

    pg_trace.beginDraw(); //描画の開始

    //描画ここから---------------------------
    pg_trace.strokeWeight(trace_width); //軌跡の線の幅の設定

    for (int i=0; i<pop; i++) {
      //線の色の設定
      pg_trace.stroke(b[i].color_r + b[i].r + b[i].r2, b[i].color_g + b[i].g, b[i].color_b + b[i].b, 200);

      //i番目のボイドのx座標・y座標
      float ix0 = b[i].pos.x; 	
      float iy0 = b[i].pos.y; 			
      //i番目のボイドの1フレーム前のx座標・y座標
      float ix1 = b[i].pos1.x; 	
      float iy1 = b[i].pos1.y; 		

      //1フレーム前の位置と線を結ぶ	     		
      pg_trace.line(ix0, iy0, ix1, iy1);
    }
    //描画ここまで---------------------------

    pg_trace.endDraw(); //描画の終了
  }


  void drawConnectLayer() {

    pg_connect.beginDraw();
    pg_connect.clear();

    for (int i=0; i<pop; i++) {
      for (int j=i+1; j<pop; j++) {

        if (b[i].isVisible(b[j]) && b[i].dead==false && b[i].sick==false) {
          pg_connect.stroke(b[i].color_r + b[i].r + b[i].r2, b[i].color_g + b[i].g, b[i].color_b + b[i].b, 200);
          pg_connect.line(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);
        }
      }
    }

    pg_connect.endDraw();
  }

  void drawClusterLayer() {

    pg_cluster.noStroke();
    pg_cluster.fill(b[0].color_r + b[0].r, b[0].color_g + b[0].g, b[0].color_b + b[0].b, 80);

    pg_cluster.beginDraw();
    pg_cluster.clear();

    BoidsCluster bc = new BoidsCluster(b);

    int gsum = bc.countCluster(pop/12);

    for (int g=0; g<gsum; g++) {
      Pos cp = bc.getClusterPos(g);
      float cd = bc.getClusterDistance(g);
      int cs = bc.getClusterSize(g);

      pg_cluster.ellipse(cp.x, cp.y, cd*2, cd*2);
    }

    pg_cluster.endDraw();
  }

  //ボイドレイヤを本画面に出力
  void showBody() {
    image(pg_body, 0, 0);
  }

  //トレースレイヤを本画面に出力
  void showTrace() {
    image(pg_trace, 0, 0);
  }

  void showConnect() {
    for (int i=0; i<pop; i++) {
      for (int j=i+1; j<pop; j++) {
        if (b[i].isVisible(b[j])) {
          b[i].setColorBody();
        }
      }
    }
    image(pg_connect, 0, 0);
  }

  void showCluster() {
    image(pg_cluster, 0, 0);
  }

  //トレースレイヤを消去
  void clearTrace() {
    pg_trace.beginDraw();
    pg_trace.clear();
    pg_trace.endDraw();
  }

  //ルール1（結合ルール）をここに書きましょう。
  void applyRule1() {	

    for (int i=0; i<pop; i++) {
      int count = 0;
      float sumx = 0;
      float sumy = 0;

      for (int j=0; j<pop; j++) {
        if (b[i].sick==false && j !=i && b[i].isVisible(b[j]) && b[i].dead==false && b[i].sick==false) {

          count++;
          sumx += b[j].pos.x;
          sumy += b[j].pos.y;
        }
      }

      if (count>0) {
        float ax = sumx/count;
        float ay = sumy/count;

        float c = dist(b[i].pos.x, b[i].pos.y, ax, ay)*0.7;

        Vel avel = new Vel((ax - b[i].pos.x)/c, (ay - b[i].pos.y)/c);
        b[i].vel.x += avel.x;
        b[i].vel.y += avel.y;
      }
    }
  }	
  
  //ルール2（分離ルール）をここに書きましょう。
  void applyRule2() {


    for (int i=0; i<pop; i++) {

      for (int j=0; j<pop; j++) {
        if (j !=i && b[i].isNeighbor(b[j]) && b[i].dead==false && b[i].sick==false) {

          //print("a");

          float D = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);

          Vel avel = new Vel(5*(b[i].pos.x - b[j].pos.x)/D, 5*(b[i].pos.y - b[j].pos.y)/D);

          b[i].vel.x += avel.x;
          b[i].vel.y += avel.y;
        }
      }
    }
  }
  
  //ルール3（整列ルール）をここに書きましょう. 
  void applyRule3() {

    for (int i=0; i<pop; i++) {
      int count = 0;
      float sumx = 0;
      float sumy = 0;

      for (int j=0; j<pop; j++) {
        if (j !=i && b[i].isVisible(b[j]) && b[i].dead==false && b[i].sick==false) {

          count++;
          sumx += b[j].vel.x;
          sumy += b[j].vel.y;
        }
      }

      if (count>0) {
        float ax = sumx/count;
        float ay = sumy/count;

        //Vel avel = new Vel(0.1*(ax - b[i].pos.x), 0.1*(ay - b[i].pos.y));
        b[i].vel.x = 0.05*ax+(1-0.05)*b[i].vel.x;
        b[i].vel.y = 0.05*ay+(1-0.05)*b[i].vel.y;
      }
    }
  }

  void applyRule4() {

    for (int i=0; i<pop; i++) {
      if (b[i].sick == true && b[i].s_count == 2) {
        b[i].color_r = 255;
        b[i].color_g = 255;
        b[i].color_b = 255;
        b[i].r2 = 255;
        b[i].r = 255;
        b[i].g = 255;
        b[i].b = 255;
      }
      if (b[i].sick == true && b[i].s_count < 2) {
        for (int j=0; j<pop; j++) {
          if (j !=i && b[j].sick==false && b[j].dead==false && b[i].isVisible(b[j])) {

            float D = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);

            Vel avel = new Vel(5*(b[i].pos.x - b[j].pos.x)/D, 5*(b[i].pos.y - b[j].pos.y)/D);

            b[j].vel.x += avel.x;
            b[j].vel.y += avel.y;

            b[j].changeColorBlue();

            if ((b[j].color_b + b[j].b) > 255 && (b[j].color_g + b[j].g) < 100 && (b[j].color_r + b[j].r2) < 50) { 
              b[j].body_size = 15;
              b[j].sick = true;
              b[j].vel.x /= 2;
              b[j].vel.y /= 2;
              b[i].s_count++;
            }
          }
        }
      }
    }
  }
  
   void applyRule5() {   
     for (int i=0; i<pop; i++) {
      if(b[i].color_r + b[i].r + b[i].r2 > 255 && b[i].color_g + b[i].g < 30){
        
        b[i].color_r = 255;
        b[i].color_g = 255;
        b[i].color_b = 255;
        b[i].r2 = 255;
        b[i].r = 255;
        b[i].g = 255;
        b[i].b = 255;
        b[i].dead = true;
      }
     }
    }

  //マウスで押した点へと引き込まれるルールを書いてください. 
  void ruleAttractor() {

    float c = 0.1;

    for (int i=0; i<pop; i++) {
      //i番目のボイドの位置座標・速度
      Pos ipos = b[i].pos; 
      //Vel ivel = b[i].vel;

      Pos apos = new Pos(mouseX, mouseY);

      //ここから適切な処理を追加してください. 
      Vel avel = new Vel(c*(apos.x - ipos.x), c*(apos.y - ipos.y));

      b[i].vel.x += avel.x;
      b[i].vel.y += avel.y;
    }
  }

  //マウスで押した点から斥力が発生するようなルールを書いてください
  //ただし, 距離が100ピクセル未満となったときのみ斥力が発生するものとします. 
  void ruleSeparator() {
    for (int i=0; i<pop; i++) {
      //i番目のボイドの位置座標・速度
      Pos ipos = b[i].pos;	
      Vel ivel = b[i].vel;
      //i番目のボイドとクリックした位置の距離（ピクセル）
      float dis = dist(ipos.x, ipos.y, mouseX, mouseY);

      //ここから適切な処理を追加してください.
    }
  }
}
