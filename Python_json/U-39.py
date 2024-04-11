#!/usr/bin/python3
import os
import json

def check_web_service_link_usage_restriction_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-39",
        "위험도": "상",
        "진단 항목": "웹서비스 링크 사용금지 (AIX)",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "심볼릭 링크, aliases 사용 제한"
    }

    # Paths to check - adjust based on your AIX web server configurations
    config_paths = [
        "/usr/IBM/HTTPServer/conf/httpd.conf",  # Example for IBM HTTP Server
        # "/etc/httpd/conf/httpd.conf",  # Another common location
    ]

    found_vulnerability = False

    for config_path in config_paths:
        if os.path.exists(config_path):
            with open(config_path, 'r') as file:
                content = file.read()
                if 'Options FollowSymLinks' in content and 'Options -FollowSymLinks' not in content:
                    found_vulnerability = True
                    results["진단 결과"] = "취약"
                    results["현황"].append(f"{config_path} 파일에 심볼릭 링크 사용을 제한하지 않는 설정이 포함되어 있습니다.")
                    break  # Found vulnerability, no need to check further

    if not found_vulnerability:
        results["진단 결과"] = "양호"
        results["현황"].append("웹서비스 설정 파일에서 심볼릭 링크 사용이 적절히 제한되어 있습니다.")

    return results

def main():
    results = check_web_service_link_usage_restriction_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
