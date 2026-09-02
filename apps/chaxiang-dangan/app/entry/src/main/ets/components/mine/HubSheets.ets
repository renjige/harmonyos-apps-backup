import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { OrganizeHint, TeaItem, TeaList, TeaPlan, ThemeAlbum } from '../../models/TeaModels'
import { TeaNav } from '../../services/TeaNav'
import { TeaStatsService } from '../../services/TeaStatsService'
import { TeaStore } from '../../services/TeaStore'

@Component
export struct SearchSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State q: string = ''
  @State teas: TeaItem[] = []

  aboutToAppear(): void {
    this.teas = TeaStore.teas()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('搜索')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭').fontSize(Theme.type.subhead).fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { TeaNav.closeSearch() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      TextInput({ text: this.q, placeholder: '茶名 / 产地 / 故事' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .onChange((v: string): void => {
          this.q = v
          this.teas = TeaStore.search(v)
        })
      List({ space: 8 }) {
        ForEach(this.teas, (t: TeaItem) => {
          ListItem() {
            Text(t.name)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .padding(12)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => {
                TeaNav.closeSearch()
                TeaNav.openTea(t.id)
              })
          }
        }, (t: TeaItem) => t.id)
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}

@Component
export struct ListHubSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State name: string = ''
  @State intro: string = ''
  @State lists: TeaList[] = []
  @State pickId: string = ''
  @State teas: TeaItem[] = []
  @State toastText: string = ''
  @State pickRev: number = 0

  aboutToAppear(): void {
    this.refresh()
  }

  private refresh(): void {
    this.lists = TeaStore.lists().slice()
    this.teas = TeaStore.teas().slice()
    this.pickRev += 1
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private selectList(id: string): void {
    this.pickId = id
  }

  private isInPick(teaId: string): boolean {
    const list = TeaStore.findList(this.pickId)
    if (list === null) {
      return false
    }
    return list.teaIds.indexOf(teaId) >= 0
  }

  private async joinTea(teaId: string): Promise<void> {
    if (this.pickId.length === 0) {
      this.showToast('请先点选上方一个茶单')
      return
    }
    const already = this.isInPick(teaId)
    await TeaStore.addTeaToList(this.pickId, teaId)
    this.refresh()
    this.showToast(already ? '这款茶已在茶单中' : '已加入茶单')
  }

  private async add(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.showToast('请填写茶单名称')
      return
    }
    const l = new TeaList()
    l.id = TeaStore.newId('list_')
    l.name = this.name.trim()
    l.intro = this.intro.trim()
    await TeaStore.saveList(l)
    this.name = ''
    this.intro = ''
    this.pickId = l.id
    this.refresh()
    this.showToast('茶单已创建，点下方茶品加入')
  }

  @Builder
  listRow(l: TeaList) {
    Column({ space: 4 }) {
      Text(l.name).fontSize(Theme.type.subtitleS).fontColor(Theme.colors().textPrimary)
      Text(`${l.teaIds.length} 款茶${l.intro.length > 0 ? ' · ' + l.intro : ''}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.pickId === l.id ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .onClick((): void => { this.selectList(l.id) })
  }

  @Builder
  teaJoinRow(t: TeaItem) {
    Row() {
      Text(t.name)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(this.isInPick(t.id) ? '已加入' : '加入')
        .fontSize(Theme.type.caption)
        .fontColor(this.isInPick(t.id) ? Theme.colors().textSecondary : Theme.colors().brandOnPrimary)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.isInPick(t.id) ? Theme.colors().surfaceSubtle : Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { void this.joinTea(t.id) })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s3 }) {
        Row() {
          Text('我的茶单').fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary).layoutWeight(1)
          Text('关闭').fontColor(Theme.colors().brandPrimary).onClick((): void => { TeaNav.closeSheet('listSheetOpen') })
        }.padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        TextInput({ text: this.name, placeholder: '茶单名称，如日常饮用' })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .onChange((v: string) => { this.name = v })
        TextInput({ text: this.intro, placeholder: '简介' })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .onChange((v: string) => { this.intro = v })
        AppButton({ label: '创建茶单', variant: 'primary', onTap: (): void => { void this.add() } })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Column({ space: 8 }) {
            if (this.lists.length === 0) {
              AppEmpty({ title: '还没有茶单', description: '用茶单整理口粮、珍品或想分享的茶。' })
            }
            ForEach(this.lists, (l: TeaList) => {
              this.listRow(l)
            }, (l: TeaList) => `${l.id}-${l.teaIds.length}-${this.pickRev}`)

            if (this.pickId.length > 0) {
              Text('点选茶品加入该茶单')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .margin({ top: Theme.space.s3 })
              if (this.teas.length === 0) {
                Text('还没有茶档案，请先去茶库新增。')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
              }
              ForEach(this.teas, (t: TeaItem) => {
                this.teaJoinRow(t)
              }, (t: TeaItem) => `join-${t.id}-${this.pickRev}`)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 48 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AlbumHubSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State name: string = ''
  @State intro: string = ''
  @State story: string = ''
  @State albums: ThemeAlbum[] = []
  @State pickId: string = ''
  @State teas: TeaItem[] = []
  @State toastText: string = ''
  @State pickRev: number = 0

  aboutToAppear(): void {
    this.refresh()
  }

  private refresh(): void {
    this.albums = TeaStore.albums().slice()
    this.teas = TeaStore.teas().slice()
    this.pickRev += 1
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private selectAlbum(id: string): void {
    this.pickId = id
  }

  private isInPick(teaId: string): boolean {
    const album = TeaStore.findAlbum(this.pickId)
    if (album === null) {
      return false
    }
    return album.teaIds.indexOf(teaId) >= 0
  }

  private async joinTea(teaId: string): Promise<void> {
    if (this.pickId.length === 0) {
      this.showToast('请先点选上方一个主题册')
      return
    }
    const already = this.isInPick(teaId)
    await TeaStore.addTeaToAlbum(this.pickId, teaId)
    this.refresh()
    this.showToast(already ? '这款茶已在主题中' : '已加入主题册')
  }

  private async add(): Promise<void> {
    if (this.name.trim().length === 0) {
      this.showToast('请填写主题名')
      return
    }
    const a = new ThemeAlbum()
    a.id = TeaStore.newId('alb_')
    a.name = this.name.trim()
    a.intro = this.intro.trim()
    a.story = this.story.trim()
    await TeaStore.saveAlbum(a)
    this.name = ''
    this.intro = ''
    this.story = ''
    this.pickId = a.id
    this.refresh()
    this.showToast('主题已创建，点下方茶品加入')
  }

  @Builder
  albumRow(a: ThemeAlbum) {
    Column({ space: 4 }) {
      Text(a.name).fontSize(Theme.type.subtitleS).fontColor(Theme.colors().textPrimary)
      Text(`${a.teaIds.length} 款茶 · ${a.story.length > 0 ? a.story : (a.intro.length > 0 ? a.intro : '暂无简介')}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .maxLines(2)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.pickId === a.id ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
    .onClick((): void => { this.selectAlbum(a.id) })
  }

  @Builder
  teaJoinRow(t: TeaItem) {
    Row() {
      Text(t.name)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(this.isInPick(t.id) ? '已加入' : '加入')
        .fontSize(Theme.type.caption)
        .fontColor(this.isInPick(t.id) ? Theme.colors().textSecondary : Theme.colors().brandOnPrimary)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.isInPick(t.id) ? Theme.colors().surfaceSubtle : Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { void this.joinTea(t.id) })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s3 }) {
        Row() {
          Text('茶主题册').fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary).layoutWeight(1)
          Text('关闭').fontColor(Theme.colors().brandPrimary).onClick((): void => { TeaNav.closeSheet('albumSheetOpen') })
        }.padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        TextInput({ text: this.name, placeholder: '主题名，如我的春茶收藏' })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .onChange((v: string) => { this.name = v })
        TextArea({ text: this.story, placeholder: '写下这个主题的故事（可用文字描述画面）' })
          .height(80)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .onChange((v: string) => { this.story = v })
        AppButton({ label: '创建主题册', variant: 'primary', onTap: (): void => { void this.add() } })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.albums, (a: ThemeAlbum) => {
              this.albumRow(a)
            }, (a: ThemeAlbum) => `${a.id}-${a.teaIds.length}-${this.pickRev}`)

            if (this.pickId.length > 0) {
              Text('点选茶品加入该主题')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .margin({ top: Theme.space.s3 })
              if (this.teas.length === 0) {
                Text('还没有茶档案，请先去茶库新增。')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
              }
              ForEach(this.teas, (t: TeaItem) => {
                this.teaJoinRow(t)
              }, (t: TeaItem) => `alb-join-${t.id}-${this.pickRev}`)
            } else if (this.albums.length > 0) {
              Text('先点选一个主题册，再加入茶品')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 48 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct PlanHubSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State name: string = '年度品茶计划'
  @State target: string = '30'
  @State plans: TeaPlan[] = []

  aboutToAppear(): void {
    this.plans = TeaStore.plans()
  }

  private async add(): Promise<void> {
    const n = Number.parseInt(this.target, 10)
    const p = new TeaPlan()
    p.id = TeaStore.newId('plan_')
    p.name = this.name.trim().length > 0 ? this.name.trim() : '年度品茶计划'
    p.targetCount = Number.isNaN(n) ? 30 : n
    p.year = new Date().getFullYear()
    await TeaStore.savePlan(p)
    this.plans = TeaStore.plans()
  }

  private progress(p: TeaPlan): string {
    const done = TeaStore.teas().length
    return `${done}/${p.targetCount}`
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('茶计划').fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary).layoutWeight(1)
        Text('关闭').fontColor(Theme.colors().brandPrimary).onClick((): void => { TeaNav.closeSheet('planSheetOpen') })
      }.padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      TextInput({ text: this.name, placeholder: '计划名称' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .onChange((v: string) => { this.name = v })
      TextInput({ text: this.target, placeholder: '目标款数' })
        .type(InputType.Number)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .onChange((v: string) => { this.target = v })
      AppButton({ label: '创建计划', variant: 'primary', onTap: (): void => { void this.add() } })
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      List({ space: 8 }) {
        ForEach(this.plans, (p: TeaPlan) => {
          ListItem() {
            Column({ space: 4 }) {
              Text(p.name).fontSize(Theme.type.subtitleS).fontColor(Theme.colors().textPrimary)
              Text(`${p.year} · 进度 ${this.progress(p)}`).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
            }
            .width('100%').padding(12).backgroundColor(Theme.colors().surfaceCard).borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Start)
          }
        }, (p: TeaPlan) => p.id)
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
    }
    .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)
  }
}

@Component
export struct OrganizeSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State hints: OrganizeHint[] = []

  aboutToAppear(): void {
    this.hints = TeaStatsService.organizeHints()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('智慧整理').fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary).layoutWeight(1)
        Text('关闭').fontColor(Theme.colors().brandPrimary).onClick((): void => { TeaNav.closeSheet('organizeOpen') })
      }.padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      Text('根据你已有的档案做规则提醒，不是人工智能。')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      if (this.hints.length === 0) {
        AppEmpty({ title: '档案很整齐', description: '分类、标签和品饮都补上了。' })
      }
      List({ space: 8 }) {
        ForEach(this.hints, (h: OrganizeHint) => {
          ListItem() {
            Row() {
              Column({ space: 2 }) {
                Text(h.title).fontSize(Theme.type.subtitleS).fontColor(Theme.colors().textPrimary)
                Text(h.reason).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => {
              TeaNav.closeSheet('organizeOpen')
              TeaNav.openTea(h.teaId)
            })
          }
        }, (h: OrganizeHint) => h.teaId + h.reason)
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
    }
    .width('100%').height('100%').backgroundColor(Theme.colors().surfacePage)
  }
}
