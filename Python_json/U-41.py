#!/usr/bin/python3
import os
import json

def check_web_service_area_separation_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-41",
        "위험도": "상",
        "진단 항목": "웹서비스 영역의 분리 (AIX)",
        "진단 결과": None,  # Default to None, updated based on findings
        "현황": [],
        "대응방안": "DocumentRoot 별도 디렉터리 지정"
    }

    # Specific path for IBM HTTP Server configuration file
    config_file = "/usr/IBM/HTTPServer/conf/httpd.conf"

    if os.path.exists(config_file):
        with open(config_file, 'r') as file:
            content = file.readlines()
            document_root_set = False
            vulnerable = False
            for line in content:
                if 'DocumentRoot' in line and not line.strip().startswith('#'):
                    document_root_set = True
                    path = line.split()[1].strip('"')
                    # Check if the DocumentRoot is set to a default directory
                    if path in ['/usr/IBM/HTTPServer/htdocs', '/var/www/html']:
                        vulnerable = True
                        break
            
            if not document_root_set:
                results["진단 결과"] = "취약"
                results["현황"].append(f"{config_file}에 Apache DocumentRoot가 설정되지 않았습니다.")
            elif vulnerable:
                results["진단 결과"] = "취약"
                results["현황"].append(f"{config_file}에 Apache DocumentRoot가 기본 디렉터리로 설정되었습니다.")
            else:
                results["진단 결과"] = "양호"
                results["현황"].append(f"{config_file}에 Apache DocumentRoot가 별도의 디렉터리로 적절히 설정되어 있습니다.")
    else:
        results["진단 결과"] = "오류"
        results["현황"].append("웹서비스 설정 파일을 찾을 수 없습니다.")

    return results

def main():
    results = check_web_service_area_separation_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
