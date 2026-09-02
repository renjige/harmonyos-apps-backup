import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { LifePageShell } from '../components/life/LifePageShell'
import { LifeTag } from '../models/LifeHubModels'
import { JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'
import { JournalChoice } from '../services/JournalCatalog'

@Component
export struct TagManagePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onRequireAuth: () => void = () => {}
  @State tags: LifeTag[] = []
  @State selected: string = ''
  @State formName: string = ''
  @State formCat: string = 'custom'
  @State matched: JournalItem[] = []
  @State hint: string = ''
  private cats: JournalChoice[] = [
    new JournalChoice('photo', '照片'),
    new JournalChoice('food', '美食'),
    new JournalChoice('travel', '旅行'),
    new JournalChoice('family', '家庭'),
    new JournalChoice('custom', '自定义')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.tags = await LifeHubStore.loadTags()
    await this.applyFilter()
  }

  private async applyFilter(): Promise<void> {
    this.matched = []
    if (this.selected.length === 0 || !AuthService.isLoggedIn()) {
      return
    }
    let name = ''
    for (const t of this.tags) {
      if (t.id === this.selected) {
        name = t.name
      }
    }
    const diaries = await JournalBizService.cachedDiaries(this.currentUsername)
    for (const d of diaries) {
      let hit = false
      for (const tag of d.tags) {
        if (tag === name) {
          hit = true
        }
      }
      if (hit) {
        this.matched.push(d)
      }
    }
  }

  private async addTag(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    const created = await LifeHubStore.addTag(this.formName, this.formCat)
    if (created === undefined) {
      this.hint = LifeHubStore.lastError
      return
    }
    this.formName = ''
    this.hint = ''
    await this.reload()
  }

  private async deleteTag(id: string): Promise<void> {
    const ok = await LifeHubStore.removeTag(id)
    if (!ok) {
      this.hint = LifeHubStore.lastError
      return
    }
    if (this.selected === id) {
      this.selected = ''
    }
    await this.reload()
  }

  build() {
    LifePageShell({
      title: '生活标签',
      subtitle: '自定义标签 · 按标签筛选笺语',
      onClose: (): void => { LifeHubNav.backOrClose() },
      body: () => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.formName, placeholder: '新标签名称' })
        .width('100%')
        .height(44)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.formName = v })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cats, (c: JournalChoice) => {
          Text(c.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.formCat === c.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.formCat === c.id ?
              Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.formCat = c.id })
        }, (c: JournalChoice) => c.id)
      }
      .width('100%')
      AppButton({
        label: '添加标签',
        onTap: (): void => { void this.addTag() }
      })
      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
      }
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tags, (t: LifeTag) => {
          Row({ space: 6 }) {
            Text(t.name)
              .fontSize(Theme.type.caption)
              .fontColor(this.selected === t.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            if (!t.builtin) {
              Column() {
                AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: this.selected === t.id ?
                  Theme.colors().brandOnPrimary : Theme.colors().danger })
              }
              .onClick((): void => { void this.deleteTag(t.id) })
            }
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.selected === t.id ?
            Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .margin({ right: 8, bottom: 8 })
          .onClick((): void => {
            this.selected = this.selected === t.id ? '' : t.id
            void this.applyFilter()
          })
        }, (t: LifeTag) => t.id)
      }
      .width('100%')
      Text(this.selected.length > 0 ? '该标签下的笺语' : '点选标签以筛选历史笺语')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.selected.length > 0 && this.matched.length === 0) {
        AppEmpty({ title: '没有匹配的笺语', description: '写一页时把该标签加入心情或场景旁的生活标签即可' })
      }
      ForEach(this.matched, (item: JournalItem) => {
        JournalListCard({
          item: item,
          compact: true,
          onTap: (): void => { JournalDetailNav.openDiary(item.id) }
        })
      }, (item: JournalItem) => `tg_${item.id}`)
    }
    .width('100%')
  }
}
