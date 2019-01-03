import processing.net.*;

Client myclient;



String header;
String tail;

int MAXBYTE;

int MAX_HEADER = 4;
int MAX_DEVICE = 24;
int MAX_SENSOR1 = 24;
int MAX_SENSOR2 = 24;
int MAX_TEMP1 = 8;
int MAX_ADC = 4800;
int MAX_TEMP2 = 96;
int MAX_TAIL = 4;

int row;
int col;
int adc[];

int headerindex;
int tailindex;


public class COM_PACKET {
  public byte[] Header;
  public int Count;
  public String Device_name;
  public String sensor1_name;
  public String sensor2_name;
  public int NofDevice;
  public int row;
  public int col;
  public char[] temp1;
  public int[] adc;
  public char[] temp2;
  public byte[] Tail;
  
  public COM_PACKET(){
    Header = new byte[MAX_HEADER];
    temp1= new char[MAX_TEMP1];
    adc = new int[MAX_ADC];
    temp2 = new char[MAX_TEMP2];
    Tail = new byte[MAX_TAIL];
  }
}




class KLib2{
  public COM_PACKET compacket;
  public int[] last_frame;
  boolean isread;
  byte[] buf;
  int port;
  String serverip;
  PApplet parent;
  
  public KLib2(PApplet _parent,String _serverip, int _port)
  {
    serverip = _serverip;
    port = _port;
    parent = _parent;
    compacket = null;
    last_frame = new int[4800];
    buf = new byte[0];
    for(int i =0 ; i<4800 ; ++i)
    {
      last_frame[i] = 0;
    }
    isread = false;
  }
  
  void k_stop()
  {
    isread = false;
    myclient.stop();
  }
  
  int[] k_read()
  {
    if(!isread)
      return last_frame;
    int[] rowdata = new int[4800];
    
    byte[] packet = myclient.readBytes();
    
    for(int i =0 ; i<packet.length;++i){
      buf = append(buf,packet[i]) ;
    }
    
    for(int i = 0; i<buf.length-3; ++i){
      if(buf.length + 3 < 5003 + i){
        continue;
      }
      if(buf[i] != unhex("7E"))
      {
        continue;
      }
      if(buf[i+1] != unhex("7E") || buf[i+2] != unhex("7E") || buf[i+3] != unhex("7E")){
        continue;
      }
      /*
      print("i : ");
      println(i);
      */
      int tail = i + 4996;
      /*
      print("buf length : ");
      println(buf.length);
      print("tail : ");
      println(tail);   
      print("buf[tail] : ");
      println(buf[tail]);
      */
    
      byte tailvalue = byte(unhex("81"));
    
      //print("tailvalue : ");
      //println(tailvalue);
    
      if(buf[tail] != tailvalue)
      {
        continue;
      }
      if(buf[tail+1] != tailvalue || buf[tail+2] != tailvalue || buf[tail+3] != tailvalue){
        continue;
      }
      //println("pass all condition");
      headerindex = i;
      tailindex = tail;
      break;
    }
  
    if(headerindex <0)
      return last_frame;
    
    int count = 0;
    for(int i =0;i<4;++i){
      int temp = int(buf[headerindex+4+i]);
      if(temp<0)
        temp = temp * -1;
       
     count += temp * int(pow(16,i));
     }
    compacket.Count = count;
    
    if(headerindex+100+4800>buf.length)
      return last_frame;
    
    
     for(int i =0;i<4800;++i){
      if(buf[i]<0)
        rowdata[i] = int(buf[headerindex+100+i]);
       else
        rowdata[i] = int(buf[headerindex+100+i]);
      }
    
    byte[] nextbuf = new byte[0];
    
    for(int i = tailindex + 4 ; i < buf.length; ++i)
    {
        append(nextbuf, buf[i]);
    }
  
    buf = nextbuf;
    
    last_frame = rowdata;
        
    return rowdata;
  }
  
  void k_start()
  {
    myclient = new Client(parent, serverip, port);
    
    if(compacket == null)
      compacket = new COM_PACKET();  
    
    if(myclient.available() > 0){
    
    byte[] packet = myclient.readBytes();
    /*
    print("packetlen : ");
    println(packet.length);
    */
    for(int i =0 ; i<packet.length;++i){
      buf = append(buf,packet[i]) ;
    }
    for(int i = 0; i<buf.length-3; ++i){
      if(buf.length + 3 < 5003 + i){
        continue;
      }
    
      if(buf[i] != unhex("7E"))
      {
        continue;
      }
      if(buf[i+1] != unhex("7E") || buf[i+2] != unhex("7E") || buf[i+3] != unhex("7E")){
        continue;
      }
      //print("i : ");
      //println(i);
    
      int tail = i + 4996;
      /*
      print("buf length : ");
      println(buf.length);
      print("tail : ");
      println(tail);   
      print("buf[tail] : ");
      println(buf[tail]);
      */
    
      byte tailvalue = byte(unhex("81"));
    
      //print("tailvalue : ");
      //println(tailvalue);
    
      if(buf[tail] != tailvalue)
      {
        continue;
      }
      if(buf[tail+1] != tailvalue || buf[tail+2] != tailvalue || buf[tail+3] != tailvalue){
        continue;
      }
      //println("pass all condition");
      headerindex = i;
      tailindex = tail;
      
      break;
    }
    
    isread = true;
    
    if(headerindex <0)
      {
        return;
      }
    
    int count = 0;
    int nofdevice = 0;
    int row = 0;
    int col = 0;
  
    for(int i =0;i<4;++i){
     count += int(buf[headerindex+4+i]) * int(pow(16,i));
     nofdevice += int(buf[headerindex+80+i]) * int(pow(16,i));
     row += int(buf[headerindex+84+i]) * int(pow(16,i));
     col += int(buf[headerindex+88+i]) * int(pow(16,i));
    }
  
    compacket.Count = count;
    compacket.NofDevice = nofdevice;
    compacket.row = row;
    compacket.col = col;
  
  
    String devicename = "";
    String sensor1 = "";
    String sensor2 = "";
  
    for(int i =0;i<24;++i){
      devicename += char(buf[headerindex+8+i]);
      sensor1 += char(buf[headerindex+32+i]);
      sensor2 += char(buf[headerindex+56+i]);
    }
    compacket.Device_name = devicename;
    compacket.sensor1_name = sensor1;
    compacket.sensor2_name = sensor2;  
  
     
    }
  }
}

KLib2 kLib;

void setup(){
  size(200,200);
  
  MAXBYTE = 5000;
  
  /*
  header = str(char(unhex("7E"))) + str(char(unhex("7E"))) + str(char(unhex("7E"))) + str(char(unhex("7E")));
  tail = str(char(unhex("7F"))) + str(char(unhex("7F"))) + str(char(unhex("7F"))) + str(char(unhex("7F")));
  headerindex = -1;
  tailindex = -1;
  */
  
  kLib = new KLib2(this, "127.0.0.1", 3800);
  kLib.k_start();
}

void draw(){
  
  int[] data = kLib.k_read(); //<>// //<>//
  
  println(data);
  /*
  for(int i =0; i<4800; ++i){
    print(i);
    print(": ");
    print(data[i]);
    print(", ");
    }
    */
  /*
  print("headerindex : ");
  println(headerindex);
  print("tailindex : ");
  println(tailindex);
  
  
      
  int headerindex = buf.indexOf(header);
  int tailindex = buf.indexOf(tail);
  int tailindex = buf.indexOf(header, headerindex+4);
    
  print("headerindex+4 : ");
  println(buf.substring(headerindex,8));
   
  print("headerindex : ");
  println(headerindex);
  
  print("tailindex : ");
  println(tailindex);
  println("");
  
  for(int i=0; i<packet.length();++i){
    print(hex(packet.charAt(i)));
    print("(");
    print(i);
    print("), ");
  }
  
  println("");
  println("");
  
  if(headerindex <0|| tailindex <0 || tailindex - headerindex != 4996){
    println("clear");
    if(headerindex>-1 && tailindex>-1)
      buf = buf.substring(tailindex+4);
    return;
  }
    
  String result = buf.substring(headerindex+4,tailindex);
  */
 }
  //background(data);
