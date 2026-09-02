import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { GoalItem } from '../models/LifeHubModels'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'

@Component
export struct GoalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State items: GoalItem[] = []
  @State formTitle: string = ''
  @State confirmId: string = ''
  @State toastText: string = ''
  @State listEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.items = await LifeHubStore.loadGoals()
    this.listEpoch += 1
  }

  private async addGoal(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.showToast('请填写目标名称')
      return
    }
    const item = new GoalItem()
    item.id = LifeHubStore.newId('goal')
    item.title = this.formTitle.trim()
    item.progress = 0
    item.status = 'active'
    await LifeHubStore.upsertGoal(item)
    this.formTitle = ''
    this.showToast('已添加目标，点「进度 +10」可立刻看到变化')
    await this.reload()
  }

  private clamp(n: number): number {
    if (n < 0) {
      return 0
    }
    if (n > 100) {
      return 100
    }
    return n
  }

  private bumpById(id: string, delta: number): void {
    const next: GoalItem[] = []
    let progress = 0
    let status = 'active'
    let saved: GoalItem | undefined = undefined
    for (const row of this.items) {
      const copy = new GoalItem()
      copy.id = row.id
      copy.title = row.title
      if (row.id === id) {
        progress = this.clamp(row.progress + delta)
        status = progress >= 100 ? 'done' : 'active'
        copy.progress = progress
        copy.status = status
        saved = copy
      } else {
        copy.progress = row.progress
        copy.status = row.status
      }
      next.push(copy)
    }
    this.items = next
    this.listEpoch += 1
    if (saved !== undefined) {
      void LifeHubStore.upsertGoal(saved)
      this.showToast(status === 'done' ? '目标已完成 100%' : `进度 ${progress}%`)
    }
  }

  private markDoneById(id: string): void {
    this.bumpTo(id, 100, 'done', '已标记完成')
  }

  private bumpTo(id: string, progress: number, status: string, toast: string): void {
    const next: GoalItem[] = []
    let saved: GoalItem | undefined = undefined
    for (const row of this.items) {
      const copy = new GoalItem()
      copy.id = row.id
      copy.title = row.title
      if (row.id === id) {
        copy.progress = progress
        copy.status = status
        saved = copy
      } else {
        copy.progress = row.progress
        copy.status = row.status
      }
      next.push(copy)
    }
    this.items = next
    this.listEpoch += 1
    if (saved !== undefined) {
      void LifeHubStore.upsertGoal(saved)
      this.showToast(toast)
    }
  }

  private async confirmDelete(): Promise<void> {
    await LifeHubStore.removeGoal(this.confirmId)
    this.confirmId = ''
    this.showToast('已删除目标')
    await this.reload()
  }

  private barFill(progress: number): number {
    if (progress <= 0) {
      return 1
    }
    return progress
  }

  private barRest(progress: number): number {
    if (progress >= 100) {
      return 1
    }
    const rest = 100 - progress
    return rest > 0 ? rest : 1
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { LifeHubNav.backOrClose() })
          Column({ space: 2 }) {
            Text('生活目标')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('短期目标 · 记录进度 · 查看完成')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            TextInput({ text: this.formTitle, placeholder: '短期目标，例如：本周散步三次' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onChange((v: string) => { this.formTitle = v })
            AppButton({
              label: '添加目标',
              onTap: (): void => { void this.addGoal() }
            })
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有生活目标', description: '设一个短期目标，用进度记录慢慢靠近' })
            } else {
              ForEach(this.items, (row: GoalItem) => {
                Column({ space: Theme.space.s3 }) {
                  Text(row.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(row.status === 'done' ? `已完成 · ${row.progress}%` : `进行中 · ${row.progress}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  Row() {
                    Column()
                      .layoutWeight(this.barFill(row.progress))
                      .height(8)
                      .backgroundColor(row.progress > 0 ?
                        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                    Column()
                      .layoutWeight(this.barRest(row.progress))
                      .height(8)
                  }
                  .width('100%')
                  .height(8)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  Row({ space: Theme.space.s3 }) {
                    Column() {
                      Text('进度 -10')
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().brandPrimary)
                    }
                    .layoutWeight(1)
                    .height(44)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.lg)
                    .onClick((): void => { this.bumpById(row.id, -10) })
                    Column() {
                      Text('进度 +10')
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().brandOnPrimary)
                    }
                    .layoutWeight(1)
                    .height(44)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.lg)
                    .onClick((): void => { this.bumpById(row.id, 10) })
                  }
                  .width('100%')
                  if (row.status !== 'done') {
                    Column() {
                      Text('标记完成')
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().brandOnPrimary)
                    }
                    .width('100%')
                    .height(44)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.lg)
                    .onClick((): void => { this.markDoneById(row.id) })
                  }
                  Text('删除目标')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .width('100%')
                    .textAlign(TextAlign.Center)
                    .padding({ top: 4, bottom: 4 })
                    .onClick((): void => { this.confirmId = row.id })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (row: GoalItem) => `${row.id}_${row.progress}_${row.status}_${this.listEpoch}`)
            }
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmId.length > 0) {
        Column() {
          Column({ space: Theme.space.s3 }) {
            Text('删除这个目标？')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            AppButton({
              label: '确认删除',
              variant: 'danger',
              onTap: (): void => { void this.confirmDelete() }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.confirmId = '' }
            })
          }
          .width('80%')
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.35)')
        .zIndex(40)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
  }
}
