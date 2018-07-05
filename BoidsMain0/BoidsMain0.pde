
/* グローバル変数 */
BoidsDraw bdraw; //ボイド描画オブジェクト
int pop = 100;   //ボイドの総数

boolean MODE_TRACE = false; //軌跡モード（初期時はFALSE）
boolean MODE_CONNECT = false;
boolean MODE_CLUSTER = false;
boolean MODE_SICK = false;

//起動時の処理
void setup(){
	//ウィンドウを画面一杯に開く
	//Processing環境で「⌘+SHIFT+R」で実行するとフルスクリーンになります. 
	size(displayWidth,displayHeight); 
	background(0); //背景を黒とする. 
	frameRate(30);  //フレームレート
	
	//ボイド描画オブジェクトの生成
	bdraw = new BoidsDraw(pop, width, height);

}

//繰り返し行う処理
void draw(){

	//背景のクリア
	background(0); 

	//ボイドの状態（位置・速度）を更新
	bdraw.updCondition();

	//ボイドの描画（レイヤ）
	bdraw.drawBoidsLayer();
  
  for(int i=0; i<pop; i++){
    if(bdraw.b[i].sick==false){
    
       if(bdraw.b[i].b > 0){
             bdraw.b[i].b -= 0.5;
          }
        
       if(bdraw.b[i].r2 < 0){
             bdraw.b[i].r2 += 0.2;
          }
    
      if(MODE_CONNECT == false){
          if(bdraw.b[i].r > 0){
             bdraw.b[i].r -= 0.2;
          }
          if(bdraw.b[i].g < 0){
             bdraw.b[i].g += 0.2;
          }
      }
    }
    //bdraw.pg_connect.clear();
  }
  
  //if(MODE_CLUSTER == false){
  //  bdraw.pg_cluster.clear();
  //}
  
	if(MODE_TRACE){
		//トレースレイヤは, MODE_TRACEがTRUEのときのみ描画		
		//MODE_TRACEはSHIFTボタンによって反転
		bdraw.showTrace();
	}

  if(MODE_CONNECT){
    bdraw.showConnect();
  }
  
  if(MODE_CLUSTER){
    bdraw.showCluster();
  }
  
  //ボイドの描画（本画面）
  bdraw.showBody();
}

//キーが押されたときの処理
void keyPressed(){
	//シフトが押されるたびにトレースモードが反転します。
	if(keyCode == SHIFT){
		MODE_TRACE = !MODE_TRACE;
		bdraw.clearTrace();
	}
	//「i」が押されると, 全てのボイドの状態を初期化します。
	if(key == 'i' || key =='I'){
		bdraw.init();
	}
	//「a」が押されると, マウスを押した際に働く引力・斥力が切り替わります. 
	if(key == 'a' || key == 'A'){
		bdraw.MODE_ATTRACT = !bdraw.MODE_ATTRACT;
	}
	//「1」を押して, ルール1の適用の有無を切り替えます. 
	if(key == '1'){
		bdraw.MODE_RULE1 = !bdraw.MODE_RULE1;
	}
	//「2」を押して, ルール2の適用の有無を切り替えます. 
	if(key == '2'){
		bdraw.MODE_RULE2 = !bdraw.MODE_RULE2;
    println(bdraw.MODE_RULE2);
	}
	//「3」を押して, ルール3の適用の有無を切り替えます. 
	if(key == '3'){
		bdraw.MODE_RULE3 = !bdraw.MODE_RULE3;
	}
  if(keyCode == RIGHT){
    for(int i=0;i<pop;i++){
    bdraw.b[i].vision_change -= 2 ;
    }
  }
  if(keyCode == LEFT){
    for(int i=0;i<pop;i++){
    bdraw.b[i].vision_change += 2 ;
    }
  }
  if(key =='c' || key =='C'){ 
    MODE_CONNECT = !MODE_CONNECT;
  }
  if(key =='g' || key =='G'){
    MODE_CLUSTER = !MODE_CLUSTER;
  }
   if(key =='4'){
    bdraw.b[0].sick = true;
    bdraw.b[0].color_r = 50;
    bdraw.b[0].color_g = 100;
    bdraw.b[0].color_b = 255;
    bdraw.b[0].body_size = 15;
    bdraw.MODE_RULE4 = !bdraw.MODE_RULE4;
  }
  if(key =='5'){
    bdraw.MODE_RULE5 = !bdraw.MODE_RULE5;
  }
}
