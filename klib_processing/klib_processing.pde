import processing.net.*; //<>//

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
int packetlength;
int adc[];

int headerindex;
int tailindex;

public class COM_PACKET {
  public byte[] Header;//4
  public int Length;//4
  public int Count;//4
  public String Device_name;//20
  public String sensor1_name;//20
  public String sensor2_name;//20
  public int NofDevice;//4
  public int row;//4
  public int col;//4
  public int[] adc;//row*col
  public byte[] Tail;//4
  
  public COM_PACKET(int _row, int _col){
    Header = new byte[MAX_HEADER];
    adc = new int[_row*_col];
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
  PApplet parent; // TCP/IP member var
  
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
  
  //disconnect TCP/IP to SF3
  void k_stop()
  {
    isread = false;
    myclient.stop();
  }
  
  //read to packet func
  int[] k_read()
  {
    if(!isread)
      return last_frame;
    //read packet
    byte[] packet = myclient.readBytes();
    
    if(packet == null || packet.length <= 0)
    {
      return last_frame;
    }
    
    for(int i =0 ; i<packet.length;++i){
      buf = append(buf,packet[i]) ;
    }
    
    println();
    print(buf.length);
    println();
    print(row * col);
    
    for(int i = 0; i<buf.length-3; ++i){
      if(buf.length + 3 < row * col + 100){
        return last_frame;
      }
      if(buf[i] != unhex("7E"))
      {
        continue;
      }
      if(buf[i+1] != unhex("7E") || buf[i+2] != unhex("7E") || buf[i+3] != unhex("7E")){ //check header
        continue;
      }
      
      int tail = i + (row * col) + 96;

      byte tailvalue = byte(unhex("81"));
    
      if(buf[tail] != tailvalue)
      {
        continue;
      }
      if(buf[tail+1] != tailvalue || buf[tail+2] != tailvalue || buf[tail+3] != tailvalue){ //check tail
        continue;
      }
      headerindex = i;
      tailindex = tail;
      break;
    }
  
    if(headerindex <0)
      return last_frame;
    
    int count = 0;
    
    for(int i =0;i<4;++i){
      int temp = int(buf[headerindex+8+i]);
      if(temp<0)
        temp = temp * -1;
       
     count += temp * int(pow(16,i*2));
     }
    compacket.Count = count;
    
    int[] rowdata = new int[row*col];
    
    if(headerindex+100+row*col>buf.length)
      return last_frame;
    
    
     for(int i =0;i<row * col;++i){
      if(buf[i]<0)
        rowdata[i] = int(buf[headerindex+96+i]);
       else
        rowdata[i] = int(buf[headerindex+96+i]);
      }
    
    byte[] nextbuf = new byte[0];
    //creat next buf
    for(int i = tailindex + 4 ; i < buf.length; ++i)
    {
        append(nextbuf, buf[i]);
    }
  
    buf = nextbuf;
    
    last_frame = rowdata;
        
    return rowdata;
  }
  
  //connect TCP/IP to SF3
  void k_start()
  {
    //Create TCP/IP Client
    myclient = new Client(parent, serverip, port);
 

    while(true)
    {
    if(myclient.available() > 0){
    
      println(myclient.available());
      if(myclient.available()<5000)
        continue;
        
    byte[] packet = myclient.readBytes();
    
    boolean ispacket = false;
    
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
      if(buf[i+1] != unhex("7E") || buf[i+2] != unhex("7E") || buf[i+3] != unhex("7E")){//check header
        continue;
      }
    
      int tail = i + 4996;
      byte tailvalue = byte(unhex("81"));
 
      if(buf[tail] != tailvalue)
      {
        continue;
      }
      if(buf[tail+1] != tailvalue || buf[tail+2] != tailvalue || buf[tail+3] != tailvalue){//check tail
        continue;
      }
      headerindex = i;
      tailindex = tail;
      break;
      }
    
    isread = true;
    
    if(headerindex <0)
      {
        return;
      }
    
    packetlength = 0;
    int count = 0;
    int nofdevice = 0;
    row = 0;
    col = 0;
  
    //read device information and sensor information
    for(int i =0;i<4;++i){
      print(headerindex+80+i);
      packetlength += int(buf[headerindex+4+i]) * int(pow(16,i*2));
      count += int(buf[headerindex+8+i]) * int(pow(16,i*2));
      nofdevice += int(buf[headerindex+84+i]) * int(pow(16,i*2));
      row += int(buf[headerindex+88+i]) * int(pow(16,i*2));
      col += int(buf[headerindex+92+i]) * int(pow(16,i*2));
      }
  
    if(compacket == null)
      compacket = new COM_PACKET(row,col); 
    
    compacket.Length = packetlength;
    compacket.Count = count;
    compacket.NofDevice = nofdevice;
    compacket.row = row;
    compacket.col = col;
    println();
    print(packetlength);
    println();
    print(count);
    println();
    
    print(buf[headerindex+6]);
    println();
    
    String devicename = "";
    String sensor1 = "";
    String sensor2 = "";
    
    //read device's name and sensor's name
    for(int i =0;i<24;++i){
      devicename += char(buf[headerindex+12+i]);
      sensor1 += char(buf[headerindex+36+i]);
      sensor2 += char(buf[headerindex+60+i]);
    }
    compacket.Device_name = devicename;
    compacket.sensor1_name = sensor1;
    compacket.sensor2_name = sensor2;  
  
     break;
      }
      else
      {
        continue;
      }
    }
  }
}

KLib2 kLib;

void setup(){
  size(200,200);
  MAXBYTE = 5000;
  
  kLib = new KLib2(this, "127.0.0.1", 3800);
  kLib.k_start();
}

void draw(){
  
  int[] data = kLib.k_read(); //<>//
  
  //print(kLib.compacket.row);
  //println();
  //print(kLib.compacket.col);
  //print(data.length);
  //println();
  for(int i =0; i< kLib.compacket.col ; ++i)
  {
    for(int j =0; j< kLib.compacket.row ; ++j)
    {
      print(data[i*kLib.compacket.row + j]);
      print(" ");
    }
    println();
  }
  println();
  
 }
