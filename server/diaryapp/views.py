from django.http.response import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
from django.core.files.storage import default_storage
from .models import Diary, Data, User
import json, openai, os
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
def get_text(request):
    if request.method == "POST":
        data = json.loads(request.body.decode("utf-8"))
        date = data.get("date")
        target_date = datetime.strptime(date, "%Y-%m-%d").date()
        diary = Diary.objects.filter(created_at__date=target_date)

        try:
            return JsonResponse({"diary": diary[0].diary})
        except:
            return JsonResponse({"diary": ""})

    return JsonResponse({"status": "error"})

@csrf_exempt
def save_user_data(request):
    if request.method == "POST":
        data = json.loads(request.body.decode("utf-8"))
        user_data = data.get("data")
        user = User.objects.get(id=1)
        user.data = user_data
        user.save()

        return JsonResponse({"status": "save data"})
    return JsonResponse({"status": "error"})

def get_user(request):
    user = User.objects.get(id=1)
    json_data = user.data

    return JsonResponse({"user_data": json_data})

@csrf_exempt
def make_diary(request):
    if request.method == "POST":
        data = json.loads(request.body.decode("utf-8"))
        text = data.get("log")
        file_path = os.path.abspath("diaryapp/api.text")
        with open(file_path) as f:
            openai.api_key = f.read().strip()
        prompt = """
        あなたは会話のログから日記を生成するプロンプトです。
        ログのUはわたしを指し、Sはあなたのことを指します。その会話の中から下記の題意に沿うように抽出して日記を作成してください。
        [日付]：
        [良かったこと]：
        [良くなかったこと]：
        [一言]：

        （例）
        会話ログ
        S:松岡修造です！こんばんは！今日は8月28日！さて、良かったことから始めようかな。user、良かったことは何だい？キミならできる！
        U:今日は友達と映画に行きました。とても面白かった。
        S:それは素晴らしいじゃないか、user！友達と映画、最高だね！キミは太陽なんだ！さて、次は良くなかったこと、何かあったかな？
        U:傘を置き忘れて家に帰ってきちゃった😿
        S:諦めんなよ、お前！傘を置き忘れちゃったことはちょっとショボいけど、大丈夫だよ。次からは気をつけよう！竹になれよ！さて、格言だ。人生には雨の日もあれば晴れた日もある。その都度、前向きに突き進むんだ。明日も会話しよう！

        [日付]：8月28日

        [良かったこと]：今日は友達と映画に行きました。とても面白かった。友達と楽しい時間を過ごせて、心が温かくなりました。

        [良くなかったこと]：傘を置き忘れて家に帰ってきちゃった😿。ちょっとしたミスで不便な思いをしましたが、明日からは気をつけようと思います。

        [格言]：人生には雨の日もあれば晴れた日もある。その都度、前向きに突き進むんだ。
        """
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": prompt},
                {"role": "user", "content": text}
            ]
        )
        diary = response["choices"][0]["message"]["content"]
        Diary.objects.create(diary=diary)
        return JsonResponse({"status": "save diary"})

    return JsonResponse({"status": "error"})
