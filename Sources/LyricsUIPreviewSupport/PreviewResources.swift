//
//  File.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LyricsCore
import MusicPlayer
import LyricsXCore

public enum PreviewResources {}

public extension PreviewResources {

    static var lyricsLine: LyricsLine {
        return lyrics.lines[15]
    }

    static var lyrics: Lyrics {
        // FIXME: can't use package resources (Xcode 12.4)
        // Got this error: Sign LyricsXCore_LyricsUIPreviewSupport.bundle: bundle format unrecognized, invalid, or unsuitable
        // let url = Bundle.module.url(forResource: "1", withExtension: "lrcx", subdirectory: "Chandelier")!
        // let str = try! String(contentsOf: url, encoding: .utf8)
        return Lyrics(str)!
    }

    static var track: MusicTrack {
        return MusicTrack(
            id: "0",
            title: "Chandelier",
            album: "1000 Forms of Fear (Deluxe Version)",
            artist: "Sia",
            duration: 216.12)
    }

    static var coreState: LyricsXCoreState {
        let playbackState = PlaybackState.paused(time: 0)
        let player = MusicPlayerState(player: MusicPlayers.Virtual(track: track, state: playbackState))

        var searching = LyricsSearchingState(track: track)
        searching.currentLyrics = lyrics
        searching.searchResultSorted = [lyrics]
        searching.searchTerm = .info(title: track.title!, artist: track.artist!)

        let progressing = LyricsProgressingState(lyrics: lyrics, playbackState: playbackState)

        return LyricsXCoreState(playerState: player, searchingState: searching, progressingState: progressing)
    }
}

private let str = """
[length:216]
[id:$00000000]
[by:Kugou]
[ti:Chandelier]
[ar:Sia]
[00:00.330]Chandelier - Sia
[00:00.330][tt]<0,0><150,11><310,13><500,16><500>
[00:00.330][tr:zh-Hans]
[00:01.360]Party girls don't get hurt
[00:01.360][tt]<0,0><200,6><890,12><1250,18><1600,22><1860,26><1860>
[00:01.360][tr:zh-Hans]派对女孩，向来金刚不坏
[00:03.450]Can't feel anything  when will I learn
[00:03.450][tt]<0,0><200,6><390,11><1440,21><1620,26><1880,31><2070,33><2350,38><2350>
[00:03.450][tr:zh-Hans]麻木无感的我，究竟何时才会学乖
[00:06.150]I push it down  push it down
[00:06.150][tt]<0,0><190,2><390,7><660,10><1589,16><1829,21><2089,24><2389,28><2389>
[00:06.150][tr:zh-Hans]我一再压抑自己，不去介怀
[00:12.409]I'm the one "for a good time call"
[00:12.409][tr:zh-Hans]放荡如我 纵情好时光
[00:12.409][tt]<0,0><190,4><370,8><610,12><840,17><1080,19><1330,24><1630,29><1930,34><1930>
[00:14.529]Phone's blowin' up
[00:14.529][tt]<0,0><190,8><609,16><859,19><859>
[00:14.529][tr:zh-Hans]只迷恋声讯传情
[00:15.708]They're ringin' my doorbell
[00:15.708][tt]<0,0><240,8><460,16><680,19><1180,27><1180>
[00:15.708][tr:zh-Hans]电话快要打爆 登徒浪子狂按门铃
[00:17.298]I feel the love  feel the love
[00:17.298][tr:zh-Hans]我却感受到爱意，深深爱意
[00:17.298][tt]<0,0><210,2><400,7><650,11><1590,17><1790,22><2070,26><3110,30><3110>
[00:23.088]1  2  3 1  2  3 drink
[00:23.088][tt]<0,0><220,3><450,6><830,8><1060,11><1440,14><1860,16><2270,21><2270>
[00:23.088][tr:zh-Hans]一二三，一二三，干
[00:25.808]1  2  3 1  2  3 drink
[00:25.808][tr:zh-Hans]一二三，一二三，干
[00:25.808][tt]<0,0><210,3><510,6><850,8><1190,11><1480,14><1870,16><2150,21><2150>
[00:28.398]1  2  3 1  2  3 drink
[00:28.398][tt]<0,0><320,3><650,6><1000,8><1340,11><1650,14><2009,16><2280,21><2280>
[00:28.398][tr:zh-Hans]一二三，一二三，干
[00:31.078]Throw em back
[00:31.078][tt]<0,0><380,6><840,9><1250,14><1250>
[00:31.078][tr:zh-Hans]尽数回敬
[00:32.578]Till I lose count
[00:32.578][tt]<0,0><200,5><380,7><600,12><880,17><880>
[00:32.578][tr:zh-Hans]直到人事不省
[00:34.178]I'm gonna swing from the chandelier
[00:34.178][tt]<0,0><1990,4><2510,10><4740,16><5200,21><5430,25><7420,36><7420>
[00:34.178][tr:zh-Hans]我要像那摇荡吊灯
[00:41.958]From the chandelier
[00:41.958][tr:zh-Hans]恣意摇摆
[00:41.958][tt]<0,0><210,5><420,9><2330,19><2330>
[00:45.198]I'm gonna live like tomorrow doesn't exist
[00:45.198][tt]<0,0><1990,4><2420,10><4040,15><4270,20><5450,29><5820,37><6310,42><6310>
[00:45.198][tr:zh-Hans]我要放浪形骸 如同明天不复存在
[00:52.978]Like it doesn't exist
[00:52.978][tt]<0,0><240,5><490,8><850,16><3000,21><3000>
[00:52.978][tr:zh-Hans]明天不复存在
[00:56.268]I'm gonna fly like a bird through the night
[00:56.268][tt]<0,0><2170,4><2450,10><3950,14><4689,19><5209,21><5849,26><6119,34><6369,38><6979,44><6979>
[00:56.268][tr:zh-Hans]我要飞过天际 做穿越黑夜的百灵
[01:03.927]Feel my tears as they dry
[01:03.927][tt]<0,0><210,5><420,8><800,14><1040,17><1270,22><2040,25><2040>
[01:03.927][tr:zh-Hans]感受风干泪滴
[01:07.137]I'm gonna swing from the chandelier
[01:07.137][tt]<0,0><2350,4><2780,10><4910,16><5310,21><5560,25><7550,36><7550>
[01:07.137][tr:zh-Hans]我要像那摇荡吊灯
[01:15.007]From the chandelier
[01:15.007][tr:zh-Hans]恣意摇摆
[01:15.007][tt]<0,0><230,5><460,9><930,19><930>
[01:17.517]And I'm holding on for dear life
[01:17.517][tr:zh-Hans]我正为了可爱的生命咬牙坚持
[01:17.517][tt]<0,0><210,4><410,8><630,16><920,19><1150,23><1370,28><1730,33><1730>
[01:19.557]Won't look down won't open my eyes
[01:19.557][tt]<0,0><270,6><570,11><1139,16><1469,22><1729,27><1959,30><2289,34><2289>
[01:19.557][tr:zh-Hans]高昂头颅，双眼紧闭
[01:22.406]Keep my glass full until morning light
[01:22.406][tt]<0,0><270,5><520,8><920,14><1170,19><1390,25><1820,33><2200,39><2200>
[01:22.406][tr:zh-Hans]酒杯斟满，直到天明
[01:25.326]'Cause I'm just holding on for tonight
[01:25.326][tt]<0,0><210,7><460,11><720,16><1050,24><1320,27><1540,31><1960,38><1960>
[01:25.326][tr:zh-Hans]因我只为今夜而咬牙坚持
[01:28.066]Help me  I'm holding on for dear life
[01:28.066][tt]<0,0><220,5><510,9><740,13><1060,21><1310,24><1590,28><1820,33><2230,38><2230>
[01:28.066][tr:zh-Hans]救救我吧，我正为了可爱的生命咬牙坚持
[01:30.846]Won't look down won't open my eyes
[01:30.846][tt]<0,0><210,6><450,11><1170,16><1400,22><1620,27><1910,30><2250,34><2250>
[01:30.846][tr:zh-Hans]高昂头颅，双眼紧闭
[01:33.486]Keep my glass full until morning light
[01:33.486][tr:zh-Hans]酒杯斟满，直到天明
[01:33.486][tt]<0,0><240,5><480,8><820,14><1090,19><1330,25><1780,33><2090,39><2090>
[01:36.296]'Cause I'm just holding on for tonight
[01:36.296][tt]<0,0><220,7><470,11><760,16><1160,24><1410,27><1710,31><2060,38><2060>
[01:36.296][tr:zh-Hans]因我只为今夜而咬牙坚持
[01:38.916]On for tonight
[01:38.916][tt]<0,0><240,3><490,7><1029,14><1029>
[01:38.916][tr:zh-Hans]只为今夜
[01:40.565]Sun is up  I'm a mess
[01:40.565][tt]<0,0><280,4><500,7><1120,11><1360,15><1560,17><1840,21><1840>
[01:40.565][tr:zh-Hans]太阳升起，我置身一片狼藉
[01:42.785]Gotta get out now
[01:42.785][tt]<0,0><210,6><420,10><670,14><1020,18><1020>
[01:42.785][tr:zh-Hans]此刻必须逃离
[01:44.115]Gotta run from this
[01:44.115][tr:zh-Hans]远离此番荒谬困境
[01:44.115][tt]<0,0><260,6><460,10><700,15><1020,19><1020>
[01:45.485]Here comes the shame
[01:45.485][tt]<0,0><220,5><590,11><840,15><1070,21><1070>
[01:45.485][tr:zh-Hans]羞耻已汹汹来袭，步步逼近
[01:46.965]Here comes the shame
[01:46.965][tt]<0,0><210,5><510,11><740,15><2140,20><2140>
[01:46.965][tr:zh-Hans]羞耻已汹汹来袭，步步逼近
[01:51.375]1  2  3 1  2  3 drink
[01:51.375][tr:zh-Hans]一二三，一二三，干
[01:51.375][tt]<0,0><190,3><450,6><790,8><1110,11><1410,14><1790,16><2120,21><2120>
[01:53.875]1  2  3 1  2  3 drink
[01:53.875][tt]<0,0><330,3><660,6><1020,8><1330,11><1660,14><1990,16><2300,21><2300>
[01:53.875][tr:zh-Hans]一二三，一二三，干
[01:56.635]1  2  3 1  2  3 drink
[01:56.635][tr:zh-Hans]一二三，一二三，干
[01:56.635][tt]<0,0><330,3><650,6><990,8><1320,11><1660,14><2000,16><2270,21><2270>
[01:59.375]Throw em back
[01:59.375][tr:zh-Hans]尽数回敬
[01:59.375][tt]<0,0><340,6><770,9><1210,13><1210>
[02:00.815]Till I lose count
[02:00.815][tr:zh-Hans]直到人事不省
[02:00.815][tt]<0,0><200,5><400,7><620,12><1020,17><1020>
[02:02.395]I'm gonna swing
[02:02.395][tt]<0,0><2280,4><2630,10><4300,15><4300>
[02:02.395][tr:zh-Hans]我要恣意摇摆
[02:07.155]From the chandelier
[02:07.155][tt]<0,0><470,5><690,9><2650,20><2650>
[02:07.155][tr:zh-Hans]恣意摇摆,
[02:10.195]From the chandelier
[02:10.195][tr:zh-Hans]恣意摇摆
[02:10.195][tt]<0,0><250,5><460,9><3160,19><3160>
[02:13.535]I'm gonna live like tomorrow
[02:13.535][tt]<0,0><2190,4><2420,10><3920,15><4330,20><5310,28><5310>
[02:13.535][tr:zh-Hans]我要放浪形骸
[02:18.845]Doesn't exist
[02:18.845][tr:zh-Hans]如同明天不复存在
[02:18.845][tt]<0,0><310,8><1840,13><1840>
[02:21.165]Like it doesn't exist
[02:21.165][tt]<0,0><210,5><470,8><870,16><3040,21><3040>
[02:21.165][tr:zh-Hans]明天不复存在
[02:24.465]I'm gonna fly like a bird
[02:24.465][tr:zh-Hans]我要飞过天际
[02:24.465][tt]<0,0><1880,4><2460,10><3940,14><4790,19><5150,21><5880,25><5880>
[02:30.525]Through the night
[02:30.525][tr:zh-Hans]做穿越黑夜的百灵
[02:30.525][tt]<0,0><210,8><440,12><840,18><840>
[02:32.035]Feel my tears as they dry
[02:32.035][tt]<0,0><330,5><540,8><970,14><1210,17><1450,22><2090,25><2090>
[02:32.035][tr:zh-Hans]感受风干泪滴
[02:35.405]I'm gonna swing from the chandelier
[02:35.405][tr:zh-Hans]我要像那摇荡吊灯
[02:35.405][tt]<0,0><2130,4><2560,10><4959,16><5299,21><5519,25><7519,36><7519>
[02:43.244]From the chandelier
[02:43.244][tt]<0,0><190,5><410,9><2500,19><2500>
[02:43.244][tr:zh-Hans]恣意摇摆
[02:45.914]And I'm holding on for dear life
[02:45.914][tt]<0,0><190,4><380,8><610,16><840,19><1060,23><1250,28><1550,33><1550>
[02:45.914][tr:zh-Hans]我正为了可爱的生命咬牙坚持
[02:47.884]Won't look down won't open my eyes
[02:47.884][tt]<0,0><250,6><500,11><1070,16><1400,22><1630,27><1840,30><2449,34><2449>
[02:47.884][tr:zh-Hans]高昂头颅，双眼紧闭
[02:50.743]Keep my glass full
[02:50.743][tt]<0,0><200,5><410,8><690,14><1000,18><1000>
[02:50.743][tr:zh-Hans]酒杯斟满
[02:51.743]Until morning light
[02:51.743][tt]<0,0><220,6><710,14><1030,20><1030>
[02:51.743][tr:zh-Hans]直到天明
[02:53.543]'Cause I'm just holding on for tonight
[02:53.543][tr:zh-Hans]因我只为今夜而咬牙坚持
[02:53.543][tt]<0,0><220,7><440,11><700,16><970,24><1310,27><1650,31><1940,38><1940>
[02:56.323]Help me
[02:56.323][tt]<0,0><220,5><520,8><520>
[02:56.323][tr:zh-Hans]救救我吧
[02:56.843]I'm holding on for dear life
[02:56.843][tr:zh-Hans]我正为了可爱的生命咬牙坚持
[02:56.843][tt]<0,0><230,4><450,12><700,15><1000,19><1260,24><1930,29><1930>
[02:59.153]Won't look down won't open my eyes
[02:59.153][tt]<0,0><200,6><410,11><980,16><1190,22><1380,27><1590,30><1980,34><1980>
[02:59.153][tr:zh-Hans]高昂头颅，双眼紧闭
[03:01.663]Keep my glass full
[03:01.663][tt]<0,0><230,5><490,8><890,14><1170,18><1170>
[03:01.663][tr:zh-Hans]酒杯斟满
[03:02.833]Until morning light
[03:02.833][tt]<0,0><210,6><510,14><900,20><900>
[03:02.833][tr:zh-Hans]直到天明
[03:04.553]'Cause I'm just holding on for tonight
[03:04.553][tt]<0,0><210,7><440,11><740,16><1140,24><1360,27><1640,31><1920,38><1920>
[03:04.553][tr:zh-Hans]因我只为今夜而咬牙坚持
[03:06.883]On for tonight
[03:06.883][tr:zh-Hans]只为今夜
[03:06.883][tt]<0,0><330,3><600,7><930,14><930>
[03:08.353]On for tonight
[03:08.353][tt]<0,0><340,3><590,7><990,14><990>
[03:08.353][tr:zh-Hans]只为今夜
[03:10.053]I'm just holding on for tonight
[03:10.053][tt]<0,0><260,4><530,9><880,17><1140,20><1440,24><2060,31><2060>
[03:10.053][tr:zh-Hans]因我只为今夜而咬牙坚持
[03:12.893]I'm just holding on for tonight
[03:12.893][tr:zh-Hans]因我只为今夜而咬牙坚持
[03:12.893][tt]<0,0><220,4><600,9><1040,17><1320,20><1650,24><1920,31><1920>
[03:15.463]On for tonight
[03:15.463][tr:zh-Hans]只为今夜
[03:15.463][tt]<0,0><210,3><420,7><660,14><660>
[03:16.693]On for tonight
[03:16.693][tt]<0,0><240,3><500,7><870,14><870>
[03:16.693][tr:zh-Hans]只为今夜
[03:18.203]I'm just holding on for tonight
[03:18.203][tt]<0,0><300,4><540,9><920,17><1190,20><1460,24><1890,31><1890>
[03:18.203][tr:zh-Hans]因我只为今夜而咬牙坚持
[03:21.173]I'm just holding on for tonight
[03:21.173][tt]<0,0><250,4><610,9><910,17><1170,20><1450,24><1860,31><1860>
[03:21.173][tr:zh-Hans]因我只为今夜而咬牙坚持
[03:24.293]I'm just holding on for tonight
[03:24.293][tr:zh-Hans]因我只为今夜而咬牙坚持
[03:24.293][tt]<0,0><210,4><450,9><680,17><970,20><1300,24><1560,31><1560>
[03:26.463]On for tonight
[03:26.463][tr:zh-Hans]只为今夜
[03:26.463][tt]<0,0><220,3><440,7><680,14><680>
[03:27.733]On for tonight
[03:27.733][tt]<0,0><230,3><510,7><1110,14><1110>
[03:27.733][tr:zh-Hans]只为今夜
"""

/// Lyrics withouth time tags
//private let str = """
//[length:191]
//[ar:Anna F]
//[by:btbwb]
//[al:King in the Mirror]
//[ti:Fools]
//[00:00.880]Everybody knows it everybody's waiting
//[00:00.880][tr:zh-Hans]每个人都明白 每个人都在等
//[00:09.110]Everybody knows it is it just a kissaway
//[00:09.110][tr:zh-Hans]每个人都明白 这只是一次吻别
//[00:13.570]In the end it all gone
//[00:13.570][tr:zh-Hans]在最后一切都将消逝
//[00:18.120]Don't know why we're fighting
//[00:18.120][tr:zh-Hans]不明白为什么我们要争吵
//[00:20.440]Forgotten why we started
//[00:20.440][tr:zh-Hans]忘记了为什么我们会开始
//[00:22.710]Doesn't matter who is right
//[00:22.710][tr:zh-Hans]没关系谁对谁错
//[00:35.770]We're fools
//[00:35.770][tr:zh-Hans]我们都是傻瓜
//[01:11.470]Everyone is smiling hiding when we're losing
//[01:11.470][tr:zh-Hans]每个人都微笑着隐藏自己的失去
//[01:15.870]Facing what we can't deny
//[01:15.870][tr:zh-Hans]面对着无法忽视的事实
//[01:20.120]Everybody knows it but we never say it
//[01:20.120][tr:zh-Hans]每个人都明白 但我们却从未说出口
//[01:24.340]See it in each others eyes
//[01:24.340][tr:zh-Hans]在对方眼中寻得答案
//[02:02.710]Your Shadow's in the dark
//[02:02.710][tr:zh-Hans]你的身影在黑暗之中
//[02:20.340]It's over at the start
//[02:20.340][tr:zh-Hans]在开始之时就已结束
//[02:23.180]
//[02:35.740]We can't see what's right in front of us
//[02:35.740][tr:zh-Hans]我们不知道面对的是对是错
//[02:44.310]We'll die lonely
//[02:44.310][tr:zh-Hans]我们都将孤独终老
//[02:53.210]We can't touch what's right in front of us
//[02:53.210][tr:zh-Hans]我们无法触碰面对的是非对错
//[02:57.630]We're fools
//[02:57.630][tr:zh-Hans]我们都是傻瓜
//[03:02.480]Please try to hold me
//[03:02.480][tr:zh-Hans]请你试着拥抱我吧
//"""
