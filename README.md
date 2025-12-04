# PatternCatcher - Client 📱

![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)

> **사용자 정의 차트 패턴 기반 실시간 감지·백테스팅·AI 투자 보조 시스템**  
> 🏆 2025 한이음 드림업 장려상 수상작

[![Organization](https://img.shields.io/badge/🏠_Organization-647FBC?style=for-the-badge&logo=github&logoColor=white)](https://github.com/SynergyX-AI-Pattern)
[![Main Server](https://img.shields.io/badge/📘_Main_Server-9D84B7?style=for-the-badge&logo=github&logoColor=white)](https://github.com/SynergyX-AI-Pattern/SynergyX-Server)
[![ML Server](https://img.shields.io/badge/📗_ML_Server-B87C4C?style=for-the-badge&logo=github&logoColor=white)](https://github.com/SynergyX-AI-Pattern/SynergyX-ML-Server)

[![Demo](https://img.shields.io/badge/데모_영상-C93B47?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/KmI5lIBw4qw)
[![Presentation](https://img.shields.io/badge/발표_자료-6C94D4?style=for-the-badge&logo=googledocs&logoColor=white)](https://github.com/user-attachments/files/23898620/PatternCatcher.pdf)

<img width="100%" alt="PatternCatcher App" src="https://github.com/user-attachments/assets/24c17eaf-4506-4365-9752-37737730047c" />

---

## 📌 Overview

**PatternCatcher**는 개인 투자자가 자신만의 차트 패턴을 정의하고,  
실시간 감지 및 백테스팅을 통해 투자 전략의 유효성을 검증하는 AI 투자 보조 시스템입니다.

**Client**는 Flutter 기반 크로스 플랫폼 모바일 앱으로, 직관적인 UI/UX를 통해 차트 패턴 등록, 실시간 감지, 백테스팅, AI 주가 예측 등의 기능을 제공합니다.

- **개발 기간**: 2025.3. - 11.
- **지원 플랫폼**: Android, iOS
- **주요 역할**: 사용자 인터페이스, 데이터 시각화, 실시간 알림

---

## 📱 화면 구성

<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/28e9e6d1-2417-4314-96f1-9da0d3be5baf" width="100%"/>
      <br />
      <b>홈 화면</b><br/>
      <sub>Top 20 / AI Top 20</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/67e003b8-f02b-4bb4-b1e5-b75596e0abc4" width="100%"/>
      <br />
      <b>종목 상세</b><br/>
      <sub>차트 / AI 예측</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/73670a7e-1a1a-4f67-bfba-7cc0ba68999e" width="100%"/>
      <br />
      <b>패턴 생성</b><br/>
      <sub>드래그 방식</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/cbb50423-2795-44de-a1bf-81d25df814bd" width="100%"/>
      <br />
      <b>백테스팅 결과</b><br/>
      <sub>수익률 분석</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/2fcdd623-6705-4982-907e-e120999a86a6" width="100%"/>
      <br />
      <b>AI 종목 검색</b><br/>
      <sub>이미지 기반</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/131b430f-96af-4516-8487-519e0f554250" width="100%"/>
      <br />
      <b>감정 투자 일기</b><br/>
      <sub>AI 분석</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/f1d5bcd7-c144-44d9-b380-43d0a64434dc" width="100%"/>
      <br />
      <b>관심 종목</b><br/>
      <sub>종목 관리</sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/f800212a-5512-4d59-9633-5f79ac07a07b" width="100%"/>
      <br />
      <b>관심 종목</b><br/>
      <sub>패턴 / 백테스팅 관리</sub>
    </td>
  </tr>
</table>

---

## 🛠 Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | ![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) |
| **State Management** | ![Provider](https://img.shields.io/badge/Provider-02569B?logo=flutter&logoColor=white) ![GetX](https://img.shields.io/badge/GetX-8B5CF6?logo=flutter&logoColor=white) |
| **Networking** | ![Dio](https://img.shields.io/badge/Dio-02569B?logo=flutter&logoColor=white) ![Retrofit](https://img.shields.io/badge/Retrofit-48B983?logo=flutter&logoColor=white) |
| **Chart** | ![fl_chart](https://img.shields.io/badge/fl__chart-02569B?logo=flutter&logoColor=white) ![Syncfusion](https://img.shields.io/badge/Syncfusion-FF6C37?logo=syncfusion&logoColor=white) |
| **Push Notification** | ![Firebase](https://img.shields.io/badge/Firebase_FCM-FFCA28?logo=firebase&logoColor=black) |
| **Storage** | ![SharedPreferences](https://img.shields.io/badge/SharedPreferences-02569B?logo=flutter&logoColor=white) ![SecureStorage](https://img.shields.io/badge/SecureStorage-02569B?logo=flutter&logoColor=white) |

---

## 📁 Project Structure
```
lib/
├── main.dart                      # 앱 엔트리 포인트
├── data/                          # API 통신
├── models/                        # 데이터 모델
├── services/                      # 비즈니스 로직
├── screens/                       # 화면
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── stock_detail_screen.dart
│   ├── backtest/
│   ├── chart/
│   └── interest/
├── widgets/                       # 재사용 위젯
│   ├── common/
│   ├── backtest/
│   ├── stock_details/
│   └── emotion_diary/
└── routes/                        # 라우팅
```

---

## 🚀 주요 기능

### 1. 사용자 인증
JWT 기반 로그인/회원가입 및 자동 로그인

### 2. 홈 화면
Top 20 / AI Top 20 종목 조회 및 실시간 가격 표시

### 3. 종목 검색 및 상세
일반 검색, AI 이미지 검색, 실시간 차트 및 AI 예측/재무정보 조회

### 4. 차트 패턴 관리
드래그 방식 패턴 생성, 목록 조회, 실시간 감지 알림 설정

### 5. 백테스팅
백테스팅 실행 및 결과 분석 (승률, 수익률, 랭킹)

### 6. AI 감정 투자 일기
일기 작성, GPT-4o 기반 감정 분석 및 투자 조언 제공

### 7. 관심 종목 관리
관심 종목 등록/삭제 및 최근 조회 종목 자동 기록

### 8. 실시간 알림
FCM 푸시 알림 수신 및 알림 히스토리 관리

---

## 👥 Contributors

<div align="center">

| 이가현<br/>([@KaHeyon](https://github.com/KaHeyon)) | 이채원<br/>([@Chaewon5227](https://github.com/Chaewon5227)) |
|:---:|:---:|
| <img width="180" src="https://avatars.githubusercontent.com/u/93692881?v=4"/> | <img width="180" src="https://avatars.githubusercontent.com/u/101373869?v=4"/> |
| **Frontend · Design Lead** | **Frontend · Design** |
| <div align="left">• UI/UX 디자인<br/>• 프론트엔드 개발<br/>• 차트 컴포넌트<br/>• UX 최적화</div> | <div align="left">• 아이디어·기획<br/>• 앱 디자인<br/>• FE 개발<br/>• 백테스팅·패턴 컴포넌트</div> |

</div>

---

## 🔗 Related Repositories

- [📘 Main Server](https://github.com/SynergyX-AI-Pattern/SynergyX-Server) - Spring Boot 기반 백엔드 서버
- [📗 ML Server](https://github.com/SynergyX-AI-Pattern/SynergyX-ML-Server) - FastAPI 기반 AI 서버

---

## 📧 Contact

**Email**: patterncatcher83@gmail.com

---

<div align="center">

**PatternCatcher Client** by Team SynergyX

© 2025 Team SynergyX. All rights reserved.

</div>
