# KLib2-Processing

![Demo](img/KLib2_processing_Demo.png)

A Processing-based client example that connects to and visualizes sensor data from Snowforce 3.  
Supports real-time data acquisition, buffering, parsing, and 2D visualization via TCP/IP.

> This code is provided for demonstration purposes. Actual performance may vary depending on your system environment.

---

## Key Features

- TCP/IP-based client interface
- Real-time ADC data acquisition and parsing
- 2D grid-style data visualization example
- Lightweight and easy to run within Processing environment

---

## Development Environment

- [Processing 3](https://processing.org/download/)
- Snowforce 3  
  [Download Snowforce3.0_2022.02.17.exe](https://github.com/kitronyx/snowforce3/blob/master/Snowforce3.0_2022.02.17.exe)

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/kitronyx/klib2-processing.git
cd klib2-processing
```

### 2. Open in Processing

Open the `klib_processing.pde` file in the Processing IDE and run it.

---

## Code Overview

### `KLib2` Class

This class contains the core logic for TCP/IP communication and data handling.

| Component           | Description |
|---------------------|-------------|
| `Client myclient`   | TCP client connection object |
| `COM_PACKET`        | Structure for organizing received data (header, ADC, etc.) |
| `read()`            | Reads and parses packets from the buffer |
| `getData()`         | Returns the latest ADC data |
| `row`, `col`        | Dimensions of the sensor grid |

---

## Example Code

```java
import processing.net.*;

Client myclient;
KLib2 klib;

void setup() {
  size(800, 600);
  klib = new KLib2(this, "192.168.0.100", 7401); // Set server IP and port
}

void draw() {
  background(255);
  klib.read();

  int[] data = klib.getData();
  if (data != null) {
    for (int i = 0; i < data.length; i++) {
      int val = data[i];
      stroke(0);
      fill(map(val, 0, 1023, 0, 255));
      rect((i % 48) * 10, (i / 48) * 10, 10, 10);
    }
  }
}
```

---

## Contact

For technical support or inquiries,  
please visit **https://www.kitronyx.com/support_request** or contact your Kitronyx representative.

---

# KLib2-Processing

![Demo](img/KLib2_processing_Demo.png)

Processing 기반의 클라이언트 예제 코드로, Snowforce 3에서 센서 데이터를 연결하고 시각화할 수 있습니다.  
TCP/IP를 통한 실시간 수집, 버퍼링, 파싱, 시각화 예제를 포함합니다.

> 본 코드는 예제 용도로 제공되며, 실제 성능은 시스템 환경에 따라 달라질 수 있습니다.

---

## 주요 특징

- TCP/IP 기반 클라이언트 인터페이스
- 실시간 ADC 데이터 수신 및 처리
- 2D 그리드 기반 시각화 예제 포함
- Processing 환경에서 가볍고 간단하게 실행 가능

---

## 개발 환경

- [Processing 3](https://processing.org/download/)
- Snowforce 3  
  [Snowforce3.0_2022.02.17.exe 다운로드](https://github.com/kitronyx/snowforce3/blob/master/Snowforce3.0_2022.02.17.exe)

---

## 퀵스타트

### 1. 저장소 클론

```bash
git clone https://github.com/kitronyx/klib2-processing.git
cd klib2-processing
```

### 2. Processing에서 파일 열기

Processing IDE에서 `klib_processing.pde` 파일을 열어 실행합니다.

---

## 코드 개요

### `KLib2` 클래스

TCP/IP 통신 및 데이터 처리의 핵심 로직이 포함된 클래스입니다.

| 구성 요소         | 설명 |
|------------------|------|
| `Client myclient` | TCP 연결용 객체 |
| `COM_PACKET`     | 수신된 데이터를 구조화하는 클래스 (헤더, ADC 데이터 등 포함) |
| `read()`         | 수신 버퍼에서 패킷을 읽고 파싱 |
| `getData()`      | 최신 ADC 데이터를 반환 |
| `row`, `col`     | 센서 배열의 행/열 크기 |

---

## 예시 코드

```java
import processing.net.*;

Client myclient;
KLib2 klib;

void setup() {
  size(800, 600);
  klib = new KLib2(this, "192.168.0.100", 7401); // 서버 IP 및 포트 설정
}

void draw() {
  background(255);
  klib.read();

  int[] data = klib.getData();
  if (data != null) {
    for (int i = 0; i < data.length; i++) {
      int val = data[i];
      stroke(0);
      fill(map(val, 0, 1023, 0, 255));
      rect((i % 48) * 10, (i / 48) * 10, 10, 10);
    }
  }
}
```

---

## 문의

기술 지원 또는 문의는  
**https://www.kitronyx.co.kr/support_request** 를 방문하거나 담당자에게 문의해 주세요.
