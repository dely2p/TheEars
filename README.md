# TheEars

토끼 귀를 이용한 청기백기 게임

> 개발 예정 사항

- ~~애니메이션 사용 가능 여부 확인~~
- 실시간 사용자 얼굴 인식
- 토끼 귀 모델링
- 머리 위에 토끼 귀 붙여주기(애니메이션 가능)
- 각 버튼 누르면 각 토끼 귀 움직이기
- 청기백기 게임 랜덤으로 보여줄 문장 저장
- 게임 성공 실패 확인(타이머 기능 고민중)

## step1

> 개발 - 애니메이션 사용 가능 여부 확인

- <a href="https://www.youtube.com/watch?v=F1FyO0L6Q2Y">How To make 3D model Animation with ARKit</a> 참고
- ARKit 프로젝트 생성
- animation 가능한 dae file 생성을 위해 <a href="https://free3d.com/">free3D Model</a>과 <a href="https://www.mixamo.com/#/">Mixamo</a> 사용
- iOS에서 3D Model Animation 가능하겠다는 결론.

	<img src="./img/dancingMonster.gif" width="40%">

## step2

> 토끼 귀 모델링

- 토끼 귀 모양 모델링과 애니메이션 적용

	<img src="./img/theears_anim.gif" width="40%">
- 텍스쳐 설정 및 애니메이션 curve 수정예정
- face detection 후 토끼 귀의 크기정도를 다시 봐야할듯

## step3

> 실시간 사용자 얼굴 인식

- Timer를 두어 일정한 간격으로 얼굴인식하는 방법을 사용하려 했으나 앱 실행시 실행시간에 비례하여 화면출력 딜레이가 커지는 증상 발견
- AR Session Configuration 중 ARFaceTrackingConfiguration은 iPhone X에서만 가능(현재 가능한 test 기기: iPhone 6s)
- iPhone X 테스트 기기를 구하던지, ARFaceTrackingConfiguration이 아닌 방법으로 face detection 하는 방법을 찾아봐야겠음

## step4

> 각 버튼 누르면 각 토끼 귀 움직이기

- 기존에는 토끼 양 귀를 하나로 모델링 할 생각이었으나, 각 버튼을 누를 때마다 각각 위로나 아래로 움직이는 애니메이션을 적용 시켜야 하기 때문에 양쪽 귀를 따로 모델링 해야한다는 것을 깨달았다.
- 오른쪽 귀 애니메이션 동작과 왼쪽 귀 애니메이션은 서로 영향을 받아서는 안된다는 결론 -> SCNNode로 해결
	- SCNNode는 Scene의 계층 구조를 구성할 수 있다.
	- SCNNode는 add 되는 차례대로 rootNode의 [SCNNode]형태인 childNodes에 쌓이게 된다.
	- 이 프로젝트에서는 childNodes의 index 1과 2에 leftEarNode와 rightEarNode가 각각 들어가도록 구현했다.
- 토끼 귀 모델링 이전이기에 애니메이션이 가능한 모델링을 사용하여 각 버튼 클릭 시 각각 상호무관한 애니메이션이 잘 작동되는지 확인했다.
	
	<img src="./img/moving_node.gif" width="40%">