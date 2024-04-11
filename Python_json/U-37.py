#!/usr/bin/python3
import os
import json

def check_web_directory_access_restriction_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-37",
        "위험도": "상",
        "진단 항목": "웹서비스 상위 디렉토리 접근 금지 (AIX)",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "상위 디렉터리에 이동제한 설정"
    }

    # Assuming common IBM HTTP Server configuration locations
    config_paths = [
        "/usr/IBM/HTTPServer/conf/httpd.conf",  # Adjust as necessary for your setup
    ]
    
    found_vulnerability = False

    for config_path in config_paths:
        if os.path.isfile(config_path):
            with open(config_path, 'r') as file:
                content = file.read()
                if 'AllowOverride None' not in content:
                    found_vulnerability = True
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{config_path} 파일에 상위 디렉터리 접근 제한 설정이 없습니다.")
                    break

    if not found_vulnerability:
        results["진단 결과"] = "양호"
        results["현황"].append("웹서비스 상위 디렉터리 접근에 대한 제한이 적절히 설정되어 있습니다.")

    return results

def main():
    results = check_web_directory_access_restriction_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
