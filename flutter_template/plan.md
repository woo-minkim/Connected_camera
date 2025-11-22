# Luna 기능 구현 계획

## 1. 기반 구조 정비
- [ ] **얼굴 인식 데이터 모델링**: `lib/services/camera_service.dart`의 응답 포맷을 `FaceEvent`/`FaceInfo`(faceCount, faces[x,y,w,h]) 데이터 클래스로 정의하고, Luna 이벤트를 파싱하는 헬퍼를 추가한다.
- [ ] **글로벌 상태 공급자**: `lib/` 하위에 `controllers/face_detection_controller.dart`(또는 provider)를 만들어 앱 시작 시 모델 설치→카메라 초기화→`getEventNotification` 구독까지 담당한다. `ChangeNotifier`/`StreamController`로 faceCount·거리·timestamp를 공유해 `HomeView`, 영상 위젯 등에서 공통으로 구독하도록 한다.
- [ ] **앱 진입 시 초기화**: `lib/main.dart`에서 `FaceDetectionController.init()`을 앱 부팅 시 1회 호출하고, dispose 시 구독 해제 로직을 추가한다. 로그인 뷰에서도 상태를 읽어 다음 화면으로 전달할 수 있도록 `InheritedWidget` 혹은 provider 패턴으로 노출한다.
- [ ] **Mock/디버그 경로**: Luna 카메라가 없는 환경에서도 개발 가능하도록 controller에 디버그 플래그를 두고 더미 faceCount/face 크기를 타이머로 흘려보내 UI 검증이 가능하게 한다.

## 2. 기능 1 – SOLO/GROUP 홈 구성
- [ ] **상태 정의 & 변이 로직**: controller에서 faceCount 기준으로 `ViewingMode {idle, solo, group}`을 계산하고, 1–2초 히스테리시스를 둬 false positive를 줄인다.
- [ ] **UI 반영**: `lib/views/home_view.dart`를 `AnimatedSwitcher`/`PageTransitionSwitcher`로 감싸 `ViewingMode`별 섹션을 전환한다. `ContentCard` 리스트를 SOLO/GROUP에 맞춰 분리하고, `idle`일 때는 시계·날씨·"로그인 대기" 블럭을 추가한다.
- [ ] **CTA 연동**: 각 카드에서 `applicationManager.launch`(이미 `sub_view.dart`에서 사용 중)를 호출할 수 있도록 추상화된 `AppLauncherService`를 추가하고, mock 카드 클릭 시 실제 OTT 앱을 실행할 수 있게 만든다.
- [ ] **알림/토스트**: 모드 전환 시 `NotificationService.createNotification`을 호출해 "SOLO 모드 진입" 토스트를 띄워 사용자 피드백을 준다.

## 3. 기능 2 – 거리 기반 밝기·UI 조절
- [ ] **거리 단계 계산**: controller에서 `faces.first.w/h`를 기반으로 `DistanceLevel {near, mid, far}`와 신뢰도(confidence) 필드를 만든다. 값 변동이 잦지 않도록 moving average + 최소 지속시간을 둔다.
- [ ] **밝기 조정 서비스**: `services/display_service.dart`(신규)에 `luna://com.webos.display/control` 또는 `com.webos.settingsservice/setSystemSettings` 호출을 래핑해 밝기를 변경한다. 개발 중에는 Flutter `SystemChrome.setSystemUIOverlayStyle` 등으로 대체 가능한 모드를 둔다.
- [ ] **UI 스케일 동기화**: `MaterialApp`의 `builder`에서 `MediaQuery`를 조정하거나, `ThemeData.textTheme`를 DistanceLevel에 맞춰 리빌드해 카드·타이포 크기를 자동으로 조절한다. level 변경 시 `AnimatedTheme`로 자연스럽게 전환한다.
- [ ] **보호 로직**: 거리에 따른 밝기/스케일 변경이 일정 시간 이상 지속될 때만 Luna API로 명령을 내려 과도한 호출을 막는다. 실패 시 재시도 백오프와 로그를 추가한다.

## 4. 기능 3 – 얼굴 미감지 시 자동 정지
- [ ] **시청 상태 추적**: VideoPlayer를 사용하는 `lib/widgets/video_widget.dart`와 외부 OTT 제어(앱매니저 launch) 사이에 `PlaybackController`를 두고, 현재 재생 중인지 여부를 공통 상태로 관리한다.
- [ ] **타이머 & 이벤트**: faceCount가 0이 되는 순간 controller에서 `NoViewerTimer`(예: 10초)를 시작하고, 다시 감지되면 즉시 리셋한다. 타이머 만료 시 `PlaybackController.pause()`를 호출하고 이유를 상태로 기록한다.
- [ ] **UI/UX 처리**: 일시정지 시 `SubView`의 `CustomVideoWidget` 및 홈 화면에 반투명 모달/배너를 띄워 "시청자가 감지되지 않아 일시정지했습니다" 메시지를 보여주고, "이어보기" 버튼을 누르면 재생을 재개하며 faceCount>0인지 재확인한다.
- [ ] **외부 앱 호환**: 넷플릭스/유튜브 등 외부 앱일 때는 `luna://com.webos.media/audio` 또는 `applicationManager/close` 대신 `remotecontrol/dispatchInput`으로 일시정지 명령을 보내는 wrapper를 준비한다. 최소한 데모에서는 mock API로 UX를 설명할 수 있도록 한다.

## 5. 테스트 · 디버깅 · 데모 흐름
- [ ] **단위 테스트**: `test/face_detection_controller_test.dart` 등에서 faceCount 스트림을 시뮬레이션하여 ViewingMode/DistanceLevel/AutoPause 타이머 로직을 검증한다.
- [ ] **시나리오 테스트**: ① SOLO → GROUP 전환, ② 거리 근접/이탈, ③ faceCount 0으로 이동 후 자동 정지, ④ 사용자가 돌아와 이어보기 클릭 등 end-to-end flow를 QA 스크립트로 문서화한다.
- [ ] **로그/모니터링**: controller와 서비스에 `debugPrint` 래퍼를 두어 Luna API 호출/응답, 타이머 이벤트, 상태 변화를 로그로 남기고, 필요 시 `MemService` 기반 리소스 모니터링을 병행한다.

위 순서대로 진행하면 Luna API 얼굴 스트림을 단일 파이프라인으로 통합하고, README에 정의된 세 가지 기능을 Flutter UI와 webOS 서비스 호출로 단계적으로 완성할 수 있다.
