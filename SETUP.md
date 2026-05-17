# Xcode 프로젝트 설정 가이드

## 1. 새 프로젝트 생성

1. Xcode 실행 → **File > New > Project**
2. **iOS > App** 선택
3. 설정:
   - Product Name: `ElementarySchoolBook`
   - Team: 본인 Apple ID
   - Bundle Identifier: `com.yourname.ElementarySchoolBook`
   - Interface: **SwiftUI**
   - Language: **Swift**
4. 저장 위치: 이 저장소 루트 폴더

## 2. 소스 파일 추가

Xcode 프로젝트 생성 후:

1. 자동 생성된 `ContentView.swift` 삭제
2. `ElementarySchoolBook/` 폴더 전체를 Xcode 프로젝트 내비게이터로 드래그
3. "Copy items if needed" 체크

추가할 파일 목록:
```
ElementarySchoolBook/
├── ElementarySchoolBookApp.swift
├── Models/
│   ├── Book.swift
│   └── BookCatalog.swift
├── Services/
│   ├── BookCatalogService.swift
│   └── PDFDownloadService.swift
├── Store/
│   └── BookStore.swift
└── Views/
    ├── ContentView.swift
    ├── BookListView.swift
    ├── BookCardView.swift
    └── PDFReaderView.swift
```

## 3. 빌드 설정

### Frameworks 추가 (자동 포함됨, 별도 설정 불필요)
- PDFKit ✓ (iOS 11+)
- PencilKit ✓ (iOS 13+)

### Info.plist 설정
없음 (네트워크는 HTTPS만 사용하므로 ATS 설정 불필요)

### Deployment Target
- **iOS 16.0** 이상 (OSAllocatedUnfairLock 사용)

## 4. iPad에서 실행

### 방법 A: 케이블 연결
1. iPad를 Mac에 USB 연결
2. Xcode 상단 Device 선택기에서 iPad 선택
3. ▶ Run 버튼 (Cmd+R)

### 방법 B: 무선 빌드
1. iPad와 Mac이 같은 Wi-Fi에 연결
2. Xcode > Window > Devices and Simulators에서 iPad 페어링
3. 이후 무선으로 빌드 가능

## 5. 사용 방법

1. 학년 탭 선택 (3~6학년)
2. 원하는 교과서 카드에서 **다운로드** 버튼 탭
   - 사이트에서 PDF를 자동으로 받아옴 (수십 MB, Wi-Fi 권장)
3. 다운로드 완료 후 **열기** 버튼으로 PDF 읽기
4. Apple Pencil로 PDF 위에 직접 필기
   - 손가락: 스크롤
   - Apple Pencil: 필기
   - 툴바의 ✏️ 버튼: 손가락 필기 모드 토글
5. 닫으면 필기 내용 자동 저장
6. 새 버전이 올라오면 **업데이트** 버튼으로 최신 PDF 재다운로드

## 알려진 제한 사항 (v1)

- 필기는 전체 PDF 문서에 하나의 레이어로 저장 (페이지별 분리 없음)
- PDF 다운로드 중 앱을 종료하면 다운로드 중단됨
- 교사용 교과서, 지도서, 익힘책은 포함되지 않음 (학생용 교과서만)
