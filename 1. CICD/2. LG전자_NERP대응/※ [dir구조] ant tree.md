






```bash


my-ant-project
  |- build.xml         # Ant 빌드 스크립트 파일
  |- lib/              # 사용되는 외부 라이브러리 (예: ant-contrib.jar)
  ├── src/main/java/   ("실제 어플리케이션 소스코드 위치")
  │   │    │     └── com/lge/gdmi/모듈디렉토리...
  │   │    │                  ├── webservice/
  │   │    │                  └── nexacro/spring/servlet/
  |   |    ├── nxui/       # Nexacro 관련 파일 디렉토리
  |   |    ├── resources/  # 리소스 파일 디렉토리 (속성 파일, XML 등)
  |   |    ├── webapp/     # 웹 애플리케이션 디렉토리
  |   |    └── WEB-INF/ # 웹 애플리케이션의 WEB-INF 디렉토리
  |   |          |- classes/ # 컴파일된 클래스 파일이 있는 디렉토리
  |   |          |- lib/   # 웹 애플리케이션에 필요한 라이브러리 디렉토리
  |   |          |- jsp/   # JSP 파일 디렉토리
  |   |          |- tags/  # 사용자 정의 태그 파일 디렉토리
  |   |          |- index.html  # 웹 애플리케이션의 진입 파일
  ├── target/           # 빌드 결과물이 생성되는 디렉토리
  └── build.properties  # 빌드에 필요한 속성 파일





```