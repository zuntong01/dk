```bash

gdmi/
├── pom.xml  ("maven 빌드설정파일")
├── 
│
├── src/main/java/   ("실제 어플리케이션 소스코드 위치")
│   │   │     └── com/lge/gdmi/모듈디렉토리...
│   │   │                  ├── webservice/
│   │   │                  └── nexacro/spring/servlet/
│   │   │
│   │   ├── profiles/   ("환경별 설정파일 위치")
│   │   │   ├── dev/config/project.properties
│   │   │   │   └── spring/context-datasource.xml
│   │   │   ├── dev/config/project.properties
│   │   │   │   └── spring/context-datasource.xml
│   │   │   └── prod//config/project.properties
│   │   │       └── spring/context-datasource.xml
│   │   │
│   │   ├── resources/config/파일들...   ("어플리케이션 리소스파일 위치")
│   │   │        ├── fileupload/
│   │   │        ├── mail/
│   │   │        ├── message/
│   │   │        ├── spring/
│   │   │        │   └── context-datasource.xml
│   │   │        └── sql/
│   │   │
│   │   ├── webapp/         ("웹 어플리케이션 리소스파일 위치")
│   │   │   ├── common/
│   │   │   ├── export/
│   │   │   ├── import/
│   │   │   ├── fileupload/
│   │   │   ├── license/
│   │   │   ├── jsp/
│   │   │   ├── monitoring/
│   │   │   ├── nxui/
│   │   │   ├── resource/
│   │   │   ├── sso/
│   │   │   └── WEB-INF/            ("웹 어플리케이션 설정파일  위치")
│   │   │   │       ├── jsp/
│   │   │   │       ├── lib/
│   │   │   │       ├── prelib/
│   │   │   │       └── tags/
│   │   │   └── index.html
│   │   │
│   ├── test/       ("테스트코드와 리소스 파일 위치")
│   │   ├── java/
│   │   └── resources/
└── target/        ("maven 빌드결과파일 위치")




gdmi.war
│
(src/main/webapp 하위디렉토리 모두 복사)
├── common/
├── export/
├── import/
├── fileupload/
├── license/
├── jsp/
├── monitoring/
├── nxui/
├── resource/
├── sso/
├── WEB-INF/
│   ├── classes/
│   │   │
│   │   (src/main/java에 컴파일된 클래스파일이 위치함)
│   │   ├── com/lge/gdmi/모듈디렉토리...
│   │   │            ├── webservice/
│   │   │            └── nexacro/spring/servlet/
│   │   │
│   │   (src/main/resources 하위에 파일들이 복사됨)
│   │   ├── config/파일들...
│   │   ├── fileupload/
│   │   ├── mail/
│   │   ├── message/
│   │   ├── spring/
│   │   │   └── context-datasource.xml
│   │   └── sql/
│   │
│   (src/main/webapp/WEB-INF 하위에 파일들이 복사됨)
│   ├── lib/
│   ├── jsp/
│   ├── prelib/
│   └── tags/
│ 
└── index.html








```