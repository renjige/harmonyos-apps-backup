import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ItemRow, ProgressTrack } from './FamilyCards'
import { FamilyMedia } from '../../services/FamilyMedia'
import { CategorySuggest } from '../../services/CategorySuggest'
import { FamilyService } from '../../services/FamilyService'
import { FamilyTask, FamilyList } from '../../models/FamilyModels'

class CategoryGroup {
  cat: string = ''
  items: FamilyTask[] = []
}

@Component
export struct ListDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onListChange') listId: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  @State list: FamilyList = new FamilyList()
  @State items: FamilyTask[] = []
  @State confirmDelete: boolean = false
  onClose: () => void = () => {}
  onAddItem: () => void = () => {}
  onRemind: () => void = () => {}
  onDeleted: () => void = () => {}
  onShare: (text: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onListChange(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const found = await FamilyService.findList(this.listId)
    if (found !== undefined) {
      this.list = found
    }
    this.items = await FamilyService.items(this.listId)
  }

  private async toggleRow(it: FamilyTask): Promise<void> {
    await FamilyService.toggleItem(it)
    await this.reload()
  }

  private groupKey(g: CategoryGroup): string {
    return `${g.cat}_${g.items.length}_${FamilyService.doneCount(g.items)}`
  }

  private remain(): number {
    return this.items.length - FamilyService.doneCount(this.items)
  }

  private grouped(cat: string): FamilyTask[] {
    const out: FamilyTask[] = []
    for (const it of this.items) {
      if (it.category === cat) {
        out.push(it)
      }
    }
    return out
  }

  private categoryGroups(): CategoryGroup[] {
    const out: CategoryGroup[] = []
    const cats: string[] = CategorySuggest.categories()
    for (const cat of cats) {
      const items: FamilyTask[] = this.grouped(cat)
      if (items.length > 0) {
        const g = new CategoryGroup()
        g.cat = cat
        g.items = items
        out.push(g)
      }
    }
    return out
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('分享')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick(() => this.onShare(FamilyService.shareText(this.list, this.items)))
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(FamilyMedia.cover(this.list.coverKey, this.list.id))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(8,42,90,0.08)', 0], ['rgba(8,42,90,0.78)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: 6 }) {
              Text(this.list.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${this.items.length} 项 · ${FamilyService.doneCount(this.items)} 已完成`)
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
            }
            .padding(18)
          }
          .width('100%')

          Column({ space: 12 }) {
            Text('完成进度')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            ProgressTrack({ done: FamilyService.doneCount(this.items), total: this.items.length })
            Text(this.list.summary.length > 0 ? this.list.summary : '逐项勾选，出门更从容。')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          if (this.items.length === 0) {
            AppEmpty({
              title: '还没有事项',
              description: '添加第一件家庭事项',
              actionLabel: '添加事项',
              onAction: () => this.onAddItem()
            })
          } else {
            ForEach(this.categoryGroups(), (g: CategoryGroup) => {
              Column({ space: 4 }) {
                Text(g.cat)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .padding({ top: 8 })
                ForEach(g.items, (it: FamilyTask) => {
                  ItemRow({
                    title: it.title,
                    extra: it.qty.length > 0 ? it.qty : it.remark,
                    done: it.completed,
                    onToggle: (): void => {
                      void this.toggleRow(it)
                    }
                  })
                }, (it: FamilyTask) => `${it.id}_${it.completed ? '1' : '0'}`)
              }
              .width('100%')
              .padding({ left: 8, right: 8 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (g: CategoryGroup) => this.groupKey(g))
          }

          AppButton({ label: '添加事项', onTap: () => this.onAddItem() })
          AppButton({ label: '智慧提醒', variant: 'secondary', onTap: () => this.onRemind() })
          AppButton({
            label: this.confirmDelete ? '再点一次确认删除' : '删除家庭清单',
            variant: 'ghost',
            onTap: (): void => {
              if (!this.confirmDelete) {
                this.confirmDelete = true
                return
              }
              void FamilyService.deleteList(this.listId).then(() => this.onDeleted())
            }
          })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
