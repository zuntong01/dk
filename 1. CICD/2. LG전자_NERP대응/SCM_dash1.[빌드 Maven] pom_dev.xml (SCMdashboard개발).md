__`pom.xml.md`__

#### <b><span style="color:cyan">[스크립트 설명]</span></b>  
```bash
maven 빌드를 하기위한 빌드스크립트 (maven 프로젝트 빌드를 위한 설정파일)
※ 별도의 추가 설정파일 : (해당프로젝트에서는 별도파일에 적용된 설정은 없는듯)
    1. settings.xml : maven빌드의 글로벌 설정이 가능 / ${MAVEN경로}/conf 또는 ~/.m2 경로에 있다면 기본적용됨 (예시 : repo 설정, profile 설정등이 가능 )
    2. config.properties : pom.xml 에서 사용하는 변수 분리해서 관리 (pom.xml에 properties-maven-plugin을 사용하여 외부변수파일값을 읽어 올수 있음)
```

### <b><span style="color:cyan">[pom.xml (NTAMS 운영]</span></b>
```xml
<!-- 
  <project섹션> : Maven 프로젝트의 기본적인 구조를 정의합니다. XML 네임스페이스와 스키마 정보를 포함하여 Maven이 이 파일을 올바르게 파싱하고 검증할 수 있는 정보를 제공
    ※ POM파일임을 정의(xmlns) 하고, XML문서가 스키마참조(xmlns:xsi)하도록 하고, 스키마 파일의 위치(xsi:schemaLocation)를 정의하여 pom.xml 파일의 구조를 검증하도록 함 
-->







```
