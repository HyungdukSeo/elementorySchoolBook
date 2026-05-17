# 초등학교 교과서 뷰어 (Elementary School Book)

아이패드에서 공개된 초등학교 교과서 PDF를 받아 읽고, 애플펜슬로 필기할 수 있는 앱입니다.

## 주요 기능

| 기능 | 설명 |
|------|------|
| 학년별 교과서 목록 | 3~6학년 과목별 교과서 그리드 표시 |
| 원클릭 다운로드 | 공개 교과서 사이트에서 자동 PDF 다운로드 |
| 원클릭 업데이트 | 최신 버전 PDF 재다운로드 |
| Apple Pencil 필기 | PDF 위에 직접 손글씨 필기 |
| 필기 자동 저장 | 다음에 열어도 필기 내용 유지 |

## 교과서 목록 (2022 개정 미래엔)

| 학년 | 과목 |
|------|------|
| 3학년 | 수학(1,2), 사회(1,2), 과학(1,2), 영어, 미술, 음악, 체육 |
| 4학년 | 수학(1,2), 사회(1,2), 과학(1,2), 영어, 미술, 음악, 체육 |
| 5학년 | 수학(1,2), 사회(1,2), 과학(1,2), 영어, 미술, 음악, 체육, 실과 |
| 6학년 | 수학(1,2), 사회(1,2), 과학(1,2), 영어, 미술, 음악, 체육, 실과 |

## 교과서 데이터 출처

[미래엔 2022 개정 교과서 전시본](https://22txbook.m-teacher.co.kr/book/list.mrn?lev=1)
— 무료 공개, 가입 불필요

## 개발 환경

- **플랫폼**: iPadOS 16.0+
- **언어**: Swift 5.9 / SwiftUI
- **Frameworks**: PDFKit, PencilKit
- **대상 기기**: iPad (Apple Pencil 1세대/2세대)

## 설정 방법

**[SETUP.md](SETUP.md)** 참고

## 앱 구조

```
ElementarySchoolBook/
├── ElementarySchoolBookApp.swift    # 앱 진입점
├── Models/
│   ├── Book.swift                   # 교과서 데이터 모델
│   └── BookCatalog.swift            # 전체 교과서 목록 (하드코딩)
├── Services/
│   ├── BookCatalogService.swift     # 단축 URL 파싱
│   └── PDFDownloadService.swift     # PDF 다운로드
├── Store/
│   └── BookStore.swift              # 앱 상태 관리
└── Views/
    ├── ContentView.swift            # 학년별 탭 뷰
    ├── BookListView.swift           # 교과서 그리드
    ├── BookCardView.swift           # 교과서 카드
    └── PDFReaderView.swift          # PDF 뷰어 + PencilKit
```

## 동작 원리

1. `BookCatalog` — 교과서 ID/제목/학년 정보 하드코딩
2. 다운로드 시 `BookCatalogService` → 미래엔 사이트에서 단축 URL 파싱
3. `PDFDownloadService` → 단축 URL 리다이렉트 따라 JWT 토큰이 담긴 PDF URL 획득 → 파일 다운로드
4. `PDFReaderView` → PDFKit으로 PDF 표시, PencilKit 캔버스를 PDF documentView에 오버레이
5. Apple Pencil → 캔버스에 필기, 손가락 → PDF 스크롤

## 라이선스

개인 학습 및 교육 목적용. 교과서 PDF 저작권은 미래엔에 있습니다.
