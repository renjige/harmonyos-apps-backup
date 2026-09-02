import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppCard } from '../components/design-system/AppCard'
import { HandcraftInspiration } from '../models/HandcraftModels'
import { CreateInspirationRequest } from '../models/HandcraftModels'
import { HandcraftBizService } from '../services/HandcraftBizService'
import { AuthService } from '../services/AuthService'
import { CraftLocalStore } from '../services/CraftLocalStore'

@Component
export struct InspirationPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop embedded: boolean = false
  onRequireAuth: () => void = () => {}
  @StorageLink('currentUsername') currentUsername: string = ''
  @State items: HandcraftInspiration[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State title: string = ''
  @State content: string = ''
  @State tagsText: string = ''
  @State category: string = '日常'
  @State filterTag: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await HandcraftBizService.loadInspirations(true)
    this.loading = false
  }

  private splitTags(): string[] {
    const parts = this.tagsText.split('\n')
    const merged: string[] = []
    for (const part of parts) {
      const commaParts = part.split(',')
      for (const cp of commaParts) {
        const cnParts = cp.split('，')
        for (const cn of cnParts) {
          merged.push(cn)
        }
      }
    }
    const out: string[] = []
    for (const t of merged) {
      const s = t.trim()
      if (s.length > 0) {
        out.push(s)
      }
    }
    return out
  }

  private allTags(): string[] {
    const set: string[] = []
    for (const item of this.items) {
      for (const t of item.tags) {
        if (!set.includes(t)) {
          set.push(t)
        }
      }
    }
    return set
  }

  private filtered(): HandcraftInspiration[] {
    if (this.filterTag.length === 0) {
      return this.items
    }
    const out: HandcraftInspiration[] = []
    for (const item of this.items) {
      if (item.tags.includes(this.filterTag)) {
        out.push(item)
      }
    }
    return out
  }

  private async handleSave(): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    if (this.title.trim().length === 0) {
      this.toastText = '请填写灵感标题'
      return
    }
    const req = new CreateInspirationRequest()
    req.title = this.title.trim()
    req.content = this.content.trim()
    req.tags = this.splitTags()
    req.category = this.category
    const ok = await HandcraftBizService.createInspiration(req)
    if (ok) {
      this.title = ''
      this.content = ''
      this.tagsText = ''
      this.showForm = false
      AppStorage.setOrCreate('tabBarHidden', false)
      CraftLocalStore.bumpRefresh()
      void this.reload()
    } else {
      this.toastText = '保存失败，请检查登录'
    }
  }

  build() {
    Stack() {
      Column() {
        if (!this.embedded) {
          AppHeader({ title: '灵感', subtitle: '私人笔记，仅自己可见' })
        }
        if (!this.showForm) {
          Row({ space: Theme.space.s2 }) {
            Text('按标签筛选灵感')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .layoutWeight(1)
            Column() {
              AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().textOnInverse })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => {
              if (!AuthService.requireAuth('create_inspiration')) {
                this.onRequireAuth()
                return
              }
              this.showForm = true
              AppStorage.setOrCreate('tabBarHidden', true)
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

          if (this.allTags().length > 0) {
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                Text('全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterTag.length === 0 ?
                    Theme.colors().textOnInverse : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.filterTag.length === 0 ?
                    Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.filterTag = '' })
                ForEach(this.allTags(), (tag: string) => {
                  Text(tag)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.filterTag === tag ?
                      Theme.colors().textOnInverse : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.filterTag === tag ?
                      Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.filterTag = tag })
                }, (tag: string) => tag)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })
          }

          Column() {
            if (this.loading) {
              AppLoading({ label: '加载灵感…' })
            } else if (this.filtered().length === 0) {
              AppEmpty({
                title: '暂无灵感',
                description: this.currentUsername.length > 0 ?
                  '点击右上角 ＋ 按钮，记录第一个灵感' : '登录后可记录与管理灵感',
                actionLabel: this.currentUsername.length > 0 ? '' : '去登录',
                onAction: (): void => {
                  if (this.currentUsername.length === 0) {
                    this.onRequireAuth()
                  }
                }
              })
            } else {
              Scroll() {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.filtered(), (item: HandcraftInspiration) => {
                    AppCard({ title: item.title, variant: 'plain' }) {
                      Column({ space: 8 }) {
                        if (item.content.length > 0) {
                          Text(item.content)
                            .fontSize(Theme.type.body)
                            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                            .width('100%')
                        }
                        Flex({ wrap: FlexWrap.Wrap }) {
                          ForEach(item.tags, (tag: string) => {
                            Text(`#${tag}`)
                              .fontSize(Theme.type.caption)
                              .fontColor(Theme.colors().brandDeep)
                              .margin({ right: 8, bottom: 4 })
                          }, (tag: string) => tag)
                        }.width('100%')
                      }.width('100%')
                    }
                  }, (item: HandcraftInspiration) => item.id)
                }
                .padding({
                  left: Theme.space.pageX,
                  right: Theme.space.pageX,
                  bottom: Theme.space.s10
                })
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .align(Alignment.TopStart)
              .scrollBar(BarState.Off)
            }
          }
          .layoutWeight(1)
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        } else {
          this.InspirationForm()
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  InspirationForm() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.title, placeholder: '灵感标题' })
          .onChange((v: string) => { this.title = v })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding(Theme.space.s3)
        TextArea({ text: this.content, placeholder: '写下灵感内容…' })
          .height(120)
          .onChange((v: string) => { this.content = v })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding(Theme.space.s3)
        TextInput({ text: this.tagsText, placeholder: '标签，逗号分隔' })
          .onChange((v: string) => { this.tagsText = v })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding(Theme.space.s3)
        Row({ space: Theme.space.s3 }) {
          Column() {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => {
                this.showForm = false
                AppStorage.setOrCreate('tabBarHidden', false)
              }
            })
          }.layoutWeight(1)
          Column() {
            AppButton({
              label: '保存',
              onTap: (): void => { void this.handleSave() }
            })
          }.layoutWeight(1)
        }.width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .layoutWeight(1)
  }
}
