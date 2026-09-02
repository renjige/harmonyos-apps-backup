import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { CollectItem, NoteCat, TagLib } from '../models/CollectModels'
import { CollectStore } from '../services/CollectStore'

@Component
export struct CollectEditPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editKind: string = 'moment'
  @Prop seedId: string = ''
  @Prop presetTitle: string = ''
  @Prop presetSub: string = ''
  @Prop presetTags: string = ''
  @Prop refMatchId: string = ''
  @State item: CollectItem = CollectItem.create('moment')
  @State toastText: string = ''
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    if (this.seedId.length > 0) {
      void CollectStore.find(this.seedId).then((found): void => {
        if (found !== undefined) {
          this.item = found
        }
      })
      return
    }
    this.item = CollectItem.create(this.editKind)
    if (this.presetTitle.length > 0) {
      this.item.title = this.presetTitle
    }
    if (this.presetSub.length > 0) {
      this.item.sub = this.presetSub
    }
    if (this.presetTags.length > 0) {
      this.item.tags = this.presetTags
    }
    if (this.refMatchId.length > 0) {
      this.item.refMatchId = this.refMatchId
    }
    if (this.editKind === 'note' && this.item.extra.length === 0) {
      this.item.extra = NoteCat.all()[0]
    }
  }

  private heading(): string {
    if (this.item.kind === 'team') {
      return '球队档案'
    }
    if (this.item.kind === 'player') {
      return '球员档案'
    }
    if (this.item.kind === 'note') {
      return '赛场笔记'
    }
    if (this.item.kind === 'album') {
      return '收藏专题'
    }
    if (this.item.kind === 'perf') {
      return '球员表现卡'
    }
    return '精彩瞬间'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.item.title.trim().length === 0) {
      this.showToast('请填写标题')
      return
    }
    await CollectStore.save(this.item)
    this.showToast('已保存')
    setTimeout((): void => {
      this.onSaved()
      this.onClose()
    }, 400)
  }

  private toggleTag(tag: string): void {
    const parts = this.item.tags.split(',')
    const next: string[] = []
    let found = false
    for (const t of parts) {
      if (t.length === 0) {
        continue
      }
      if (t === tag) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(tag)
    }
    this.item.tags = next.join(',')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text(this.heading())
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            this.FieldLabel(this.item.kind === 'player' || this.item.kind === 'perf' ? '姓名' :
              (this.item.kind === 'team' ? '球队名称' : '标题'))
            TextInput({ text: this.item.title, placeholder: '必填' })
              .onChange((v: string) => { this.item.title = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            if (this.item.kind === 'moment') {
              this.FieldLabel('时间节点')
              TextInput({ text: this.item.sub, placeholder: '例如 第78分钟' })
                .onChange((v: string) => { this.item.sub = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
            }
            if (this.item.kind === 'team') {
              this.FieldLabel('所属赛事')
              TextInput({ text: this.item.sub, placeholder: '联赛/杯赛' })
                .onChange((v: string) => { this.item.sub = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
              this.FieldLabel('关注理由')
              TextInput({ text: this.item.extra, placeholder: '为什么关注这支队' })
                .onChange((v: string) => { this.item.extra = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
            }
            if (this.item.kind === 'player') {
              this.FieldLabel('所属球队 / 位置')
              TextInput({ text: this.item.sub, placeholder: '球队 · 前锋' })
                .onChange((v: string) => { this.item.sub = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
            }
            if (this.item.kind === 'perf') {
              this.FieldLabel('关联比赛')
              TextInput({ text: this.item.sub, placeholder: '哪一场' })
                .onChange((v: string) => { this.item.sub = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
              this.FieldLabel('表现星级 1-5')
              TextInput({ text: this.item.extra, placeholder: '5' })
                .type(InputType.Number)
                .onChange((v: string) => { this.item.extra = v })
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .padding(Theme.space.s3)
            }
            if (this.item.kind === 'note') {
              this.FieldLabel('笔记分类')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(NoteCat.all(), (c: string) => {
                  Text(c)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.item.extra === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.item.extra === c ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { this.item.extra = c })
                }, (c: string) => c)
              }
              .width('100%')
            }

            this.FieldLabel(this.item.kind === 'moment' ? '描述' : '评价 / 正文')
            TextArea({ text: this.item.body, placeholder: '写下你记住的细节' })
              .height(140)
              .onChange((v: string) => { this.item.body = v })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .padding(Theme.space.s3)

            this.FieldLabel('标签')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(TagLib.preset(), (t: string) => {
                Text(t)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.item.tags.indexOf(t) >= 0 ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.item.tags.indexOf(t) >= 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 6, bottom: 6 })
                  .onClick((): void => { this.toggleTag(t) })
              }, (t: string) => t)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: 100 })
        }
        .layoutWeight(1)

        Column() {
          AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.save() } })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s4 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '12%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }

  @Builder
  FieldLabel(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
  }
}
