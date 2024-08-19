import processing.net.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

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
  public double[] last_ForceFrame;
  boolean isread;
  byte[] buf;
  int port;
  String serverip;
  public String dataType;
  PApplet parent; // TCP/IP member var
  
  public KLib2(PApplet _parent,String _serverip, int _port)
  {
    serverip = _serverip;
    port = _port;
    parent = _parent;
    compacket = null;
    dataType = "Raw";
    last_frame = new int[4800];
    last_ForceFrame = new double[4800];
    buf = new byte[0];
    for(int i =0 ; i<4800 ; ++i)
    {
      last_frame[i] = 0;
      last_ForceFrame[i] = 0;
    }
    isread = false;
  }
  
  //disconnect TCP/IP to SF3
  void k_stop()
  {
    isread = false;
    myclient.stop();
  }
  
  void appendToBuffer(byte[] packet) {
    // 현재 버퍼 크기와 패킷 크기를 합한 크기의 새 버퍼를 생성
    byte[] newBuf = new byte[buf.length + packet.length];
  
    // 기존 buf 배열의 내용을 newBuf로 복사
    System.arraycopy(buf, 0, newBuf, 0, buf.length);
  
    // packet 배열의 내용을 newBuf로 복사하여 이어 붙이기
    System.arraycopy(packet, 0, newBuf, buf.length, packet.length);
  
    // buf 배열을 새 배열(newBuf)로 교체
    buf = newBuf;
  }
  double[] k_ForceRead()
  {
     if(!isread)
      return last_ForceFrame; //<>//
    //read packet
    byte[] packet = myclient.readBytes(); //<>//
    
    if(packet == null || packet.length <= 0) //<>//
    {
      return last_ForceFrame;
    }
    println( packet.length);
    appendToBuffer(packet); //<>//
    
    for(int i = 0; i<buf.length-3; ++i){
      if(buf.length + 3 < row * col + 100){
        return last_ForceFrame;
      }
      if(buf[i] != unhex("7E"))
      {
        continue;
      }
      if(buf[i+1] != unhex("7E") || buf[i+2] != unhex("7E") || buf[i+3] != unhex("7E")){ //check header
        continue;
      }
      
      int tail = i + (row * col* 8) + 96;

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
      return last_ForceFrame;
    
    int count = 0;
    
    for(int i =0;i<4;++i){
      int temp = int(buf[headerindex+8+i]);
      if(temp<0)
        temp = temp * -1;
       
     count += temp * int(pow(16,i*2));
     }
    compacket.Count = count;
    
    double[] rowdata = new double[row*col];
    
    if(headerindex+100+row*col>buf.length)
      return last_ForceFrame;
      
    //byteData.order(ByteOrder.LITTLE_ENDIAN);
    
    for (int i = 0; i < row * col; ++i) {
      int index = headerindex + 96 + i * 8;
      long bits = ((long) buf[index] & 0xFF) |
                  (((long) buf[index + 1] & 0xFF) << 8) |
                  (((long) buf[index + 2] & 0xFF) << 16) |
                  (((long) buf[index + 3] & 0xFF) << 24) |
                  (((long) buf[index + 4] & 0xFF) << 32) |
                  (((long) buf[index + 5] & 0xFF) << 40) |
                  (((long) buf[index + 6] & 0xFF) << 48) |
                  (((long) buf[index + 7] & 0xFF) << 56);
      double value = Double.longBitsToDouble(bits);
      rowdata[i] = value;
    }
    byte[] nextbuf = new byte[0]; //<>//
    //creat next buf
    for(int i = tailindex + 4 ; i < buf.length; ++i)
    {
        append(nextbuf, buf[i]);
    }
  
    buf = nextbuf;
    
    last_ForceFrame = rowdata;
        
    return rowdata;
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
    println( packet.length);
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
 

    while(true){
      if(myclient.available() > 0){                  
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
          if(buf[i+1] != unhex("7E") || buf[i+2] != unhex("7E") || buf[i+3] != unhex("7E"))
          {//check header
            continue;
          }    
          headerindex = i;
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
          // << shift
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
        
        if( compacket.Length > row*col+200)
        {
          dataType = "Force";
        }    
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
  if(kLib.dataType == "Raw"){
    int data[] = kLib.k_read();
    if (data.length == kLib.compacket.row * kLib.compacket.col) {
      for(int j = 0; j < kLib.compacket.row; ++j) {
        for(int i = 0; i < kLib.compacket.col; ++i) {
          print(data[j * kLib.compacket.col + i]);
          print(" ");
        }
        println();
      }
    }
  }
  else{
    double forceData[] = kLib.k_ForceRead();
    if (forceData.length == kLib.compacket.row * kLib.compacket.col) {
      for(int j = 0; j < kLib.compacket.row; ++j) {
        for(int i = 0; i < kLib.compacket.col; ++i) {
          printFormattedNumber(forceData[j * kLib.compacket.col + i]);
          print(" ");
        }
        println();
      }
    }
  }
  println();
}

void printFormattedNumber(double num) {
  String formatted = String.format("%.3f", num);   //the fractional part has 3 digits.
  print(formatted);
}
