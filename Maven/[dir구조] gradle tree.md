```bash


my-gradle-project
│
├── .gradle
├── gradle.propereis    ("gradle 프로젝트의 환경변수, 속성, 비밀번호등을 별도로 관리")\
│                         프로젝트 루트디렉토리에 존재하거나, gradle을 실행하는 사용자의 홈디렉토리에 위치하면 감지함)
├── build.gradle        ("gradle 빌드설정파일")
├── settings.gradle     ("프로젝트 설정정보 : 멀티프로젝트를 관리하기 위해, 루트, 서브디렉토리 정보등이 포함됨")
│
├── src/main/java/      ("실제 어플리케이션 소스코드 위치")
│   │   │   └── com/example/MyServlet.java
│   │   │ 
│   │   ├── resources/application.properties
│   │   └── webapp/
│   │       ├── WEB-INF/    ("웹 어플리케이션 설정파일  위치")
│           │       ├── web.xml
│   │       │       └── lib/
│   │       └── index.jsp
│   └── test/
│       ├── java/com/example/MyServletTest.java
│       └── resources/
│             └── test-application.properties
│
└── build/      ("빌드결과물 저장")





```