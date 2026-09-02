import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ScriptListCard } from '../components/script/ScriptListCard'
import { ScriptDetailPane } from '../components/script/ScriptDetailPane'
import { CreateScriptPage } from './CreateScriptPage'
import { LifeScript, MoodOption } from '../models/ScriptModels'
import { ScriptStore } from '../services/ScriptStore'

@Component
export struct ScriptListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State scripts: LifeScript[] = []
  @State shown: LifeScript[] = []
  @State loading: boolean = true
  @State detailScript: LifeScript | undefined = undefined
  @State showEditor: boolean = false
  @State editTarget: LifeScript | undefined = undefined
  @State toastText: string = ''
  @State keyword: string = ''
  @State moodFilter: string = '全部'
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  @Prop appName: string = '生活剧本'
  private moodChips: MoodOption[] = MoodOption.withAllChip()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.scripts = await ScriptStore.loadAll()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const out: LifeScript[] = []
    for (const s of this.scripts) {
      if (this.moodFilter !== '全部' && s.moodTag !== this.moodFilter) {
        continue
      }
      if (this.keyword.length > 0) {
        const hay = `${s.title}${s.sceneDescription}${s.prologue}`
        if (hay.indexOf(this.keyword) < 0) {
          continue
        }
      }
      out.push(s)
    }
    this.shown = out
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private openCreate(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    this.editTarget = undefined
    this.showEditor = true
  }

  private openEdit(script: LifeScript): void {
    AppStorage.setOrCreate('tabBarHidden', true)
    this.detailScript = undefined
    this.editTarget = script
    this.showEditor = true
  }

  private closeEditor(): void {
    this.showEditor = false
    this.editTarget = undefined
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column({ space: 6 }) {
            Text(this.appName)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('每个人都是自己生活的主角')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Row() {
            AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.openCreate() })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s5,
          bottom: Theme.space.s3
        })

        Column() {
          Image($r('app.media.hero_script_bg'))
            .width('100%')
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.md)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .margin({ bottom: Theme.space.s3 })

        Row({ space: 8 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
          TextInput({ text: this.keyword, placeholder: '搜索标题或场景' })
            .layoutWeight(1)
            .height(22)
            .backgroundColor(Color.Transparent)
            .placeholderColor(Theme.colors().textTertiary)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .padding(0)
            .onChange((v: string) => {
              this.keyword = v
              this.applyFilter()
            })
        }
        .width('100%')
        .height(40)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 14, right: 14 })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.moodChips, (m: MoodOption) => {
              Text(m.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.moodFilter === m.key ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.moodFilter === m.key ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.moodFilter = m.key
                  this.applyFilter()
                })
            }, (m: MoodOption) => m.key)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .constraintSize({ minHeight: 32, maxHeight: 40 })
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .margin({ bottom: Theme.space.s3 })

        if (this.loading) {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin(Theme.space.pageX)
        } else if (this.scripts.length === 0) {
          Column({ space: Theme.space.s4 }) {
            Image($r('app.media.empty_stage'))
              .width('68%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            AppEmpty({
              title: '还没有生活剧本',
              description: '点击右上角 + 创建你的第一幕',
              actionLabel: '创建剧本',
              onAction: (): void => { this.openCreate() }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
        } else if (this.shown.length === 0) {
          AppEmpty({
            title: '没有匹配的剧本',
            description: '试试换一个心情标签或清空搜索',
            actionLabel: '清除筛选',
            onAction: (): void => {
              this.keyword = ''
              this.moodFilter = '全部'
              this.applyFilter()
            }
          })
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.shown, (item: LifeScript) => {
              ListItem() {
                ScriptListCard({
                  script: item,
                  onTap: (): void => {
                    AppStorage.setOrCreate('tabBarHidden', true)
                    this.detailScript = item
                  }
                })
              }
            }, (item: LifeScript) => item.id)
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailScript !== undefined) {
        ScriptDetailPane({
          script: this.detailScript,
          onClose: (): void => {
            this.detailScript = undefined
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onEdit: (script: LifeScript): void => { this.openEdit(script) },
          onDeleted: (): void => {
            this.detailScript = undefined
            AppStorage.setOrCreate('tabBarHidden', false)
            void this.reload()
            this.showToast('剧本已删除')
          }
        })
      }

      if (this.showEditor) {
        CreateScriptPage({
          editingId: this.editTarget !== undefined ? this.editTarget.id : '',
          onClose: (): void => { this.closeEditor() },
          onSaved: (): void => {
            const wasEdit = this.editTarget !== undefined
            this.closeEditor()
            void this.reload()
            this.showToast(wasEdit ? '修改已保存' : '剧本已保存')
          }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(44,62,80,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }
}
