import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ChecklistDoc, ChecklistItem } from '../models/CommonSenseToolModels'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseLocalService } from '../services/CommonSenseLocalService'

@Component
export struct ChecklistPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('csRefresh') @Watch('onCsRefresh') csRefresh: number = 0
  @Prop @Watch('onToken') refreshToken: number = 0
  @Prop listId: string = ''
  @State lists: ChecklistDoc[] = []
  @State current: ChecklistDoc = new ChecklistDoc()
  @State draftTitle: string = ''
  @State draftItem: string = ''
  @State remarkId: string = ''
  @State remarkText: string = ''
  @State toastText: string = ''
  @State confirmRemove: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onToken(): void {
    this.reload()
  }

  private onCsRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.lists = CommonSenseLocalService.listsAll()
    if (this.listId.length > 0) {
      const found = CommonSenseLocalService.findList(this.listId)
      this.current = found !== undefined ? CommonSenseLocalService.cloneList(found) : new ChecklistDoc()
    }
  }

  private async toggleLearnedItem(itemId: string, title: string): Promise<void> {
    await CommonSenseLocalService.toggleLearned(this.listId, itemId, title)
    this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private async createList(): Promise<void> {
    const title = this.draftTitle.trim()
    if (title.length === 0) {
      this.showToast('请先填写清单名称')
      return
    }
    const doc = await CommonSenseLocalService.createList(title)
    this.draftTitle = ''
    this.reload()
    CommonSenseDetailNav.openList(doc.id)
  }

  private async addItem(): Promise<void> {
    const title = this.draftItem.trim()
    if (title.length === 0) {
      this.showToast('请填写要学的条目')
      return
    }
    await CommonSenseLocalService.addListItem(this.listId, title, '')
    this.draftItem = ''
    this.reload()
  }

  private async saveRemark(): Promise<void> {
    await CommonSenseLocalService.saveRemark(this.listId, this.remarkId, this.remarkText)
    this.remarkId = ''
    this.remarkText = ''
    this.reload()
    this.showToast('备注已保存')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { CommonSenseDetailNav.close() })
          Text(this.listId.length > 0 ? this.current.title : '常识清单')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.listId.length === 0) {
          this.ListHome()
        } else {
          this.ListDetail()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ListHome() {
    Column({ space: Theme.space.s3 }) {
      TextInput({ text: this.draftTitle, placeholder: '新建清单名称，如「厨房必会」' })
        .width('100%')
        .onChange((v: string): void => { this.draftTitle = v })
      AppButton({
        label: '创建清单',
        onTap: (): void => { void this.createList() }
      })
      if (this.lists.length === 0) {
        AppEmpty({
          title: '还没有清单',
          description: '把自己要用的常识列成清单，学完可勾选。'
        })
      } else {
        ForEach(this.lists, (doc: ChecklistDoc) => {
          Row() {
            Column({ space: 4 }) {
              Text(doc.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              Text(`${doc.learnedCount()} / ${doc.items.length} 已学 · ${doc.createdAt}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .onClick((): void => { CommonSenseDetailNav.openList(doc.id) })
        }, (doc: ChecklistDoc) => doc.id)
      }
    }
    .padding(Theme.space.pageX)
    .width('100%')
  }

  @Builder
  ListDetail() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        TextInput({ text: this.draftItem, placeholder: '添加一条要学的常识' })
          .width('100%')
          .onChange((v: string): void => { this.draftItem = v })
        AppButton({
          label: '加入清单',
          onTap: (): void => { void this.addItem() }
        })
        ForEach(this.current.items, (item: ChecklistItem) => {
          Column({ space: 8 }) {
            Row() {
              Text(item.learned ? '已学' : '未学')
                .fontSize(12)
                .fontColor(item.learned ? Theme.colors().success : Theme.colors().textSecondary)
              Text(item.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
                .maxLines(2)
            }
            .width('100%')
            if (item.remark.length > 0) {
              Text(item.remark)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            Row({ space: 8 }) {
              Text(item.learned ? '标为未学' : '标为已学')
                .fontSize(12)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .onClick((): void => { void this.toggleLearnedItem(item.id, item.title) })
              Text('备注')
                .fontSize(12)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .onClick((): void => {
                  this.remarkId = item.id
                  this.remarkText = item.remark
                })
              if (item.factId.length > 0) {
                Text('看原文')
                  .fontSize(12)
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .onClick((): void => { CommonSenseDetailNav.openFact(item.factId) })
              }
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
        }, (item: ChecklistItem) => item.id)

        if (this.remarkId.length > 0) {
          TextArea({ text: this.remarkText, placeholder: '个人备注' })
            .height(80)
            .onChange((v: string): void => { this.remarkText = v })
          AppButton({
            label: '保存备注',
            onTap: (): void => { void this.saveRemark() }
          })
        }

        AppButton({
          label: this.confirmRemove ? '再点一次确认删除' : '删除此清单',
          variant: 'danger',
          onTap: (): void => {
            if (!this.confirmRemove) {
              this.confirmRemove = true
              this.showToast('再点一次确认删除清单')
              return
            }
            void CommonSenseLocalService.removeList(this.listId)
            CommonSenseDetailNav.openLists()
          }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
