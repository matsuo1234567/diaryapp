from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
from django.core.files.storage import default_storage
from .models import Diary, Data
import json
from datetime import datetime

# Create your views here.
@csrf_exempt
def get_img(request):

    if request.method == "POST":
        # ← 受け取ったPOST画像データを保存
        res, file_name = save(request.FILES["image"])
        res = request.build_absolute_uri(res) #絶対pathに基づくURLの作成

    else:  # ← methodが'POST'ではない = 最初のページ表示時の処理
        return HttpResponse("this is post page!")

    data = Data.objects.get(id=7)
    data.url = res
    data.save()

    ret = {"url": res}

    # JSONに変換して戻す
    return JsonResponse(ret)


def save(data):
    file_name = default_storage.save(data.name, data)
    return default_storage.url(file_name), data.name
#受け取ったファイルをストレージに保存

def get_url(request):
    data = Data.objects.get(id=7)
    return JsonResponse({"url": data.url})

@csrf_exempt
def save_text(request):
    if request.method == "POST":
        data = json.loads(request.body.decode("utf-8"))
        text = data.get("text")
        Diary.objects.create(diary=text)
        return JsonResponse({"status": "save"})

    return JsonResponse({"status": "error"})

@csrf_exempt
def get_text(request):
    if request.method == "POST":
        data = json.loads(request.body.decode("utf-8"))
        date = data.get("date")
        target_date = datetime.strptime(date, "%Y-%m-%d").date()
        diary = Diary.objects.filter(created_at__date=target_date)

        return JsonResponse({"diary": diary[0].diary})
    return JsonResponse({"status": "error"})